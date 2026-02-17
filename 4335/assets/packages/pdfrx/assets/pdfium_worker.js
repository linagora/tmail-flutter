//
// A small implementation of a Web Worker that uses pdfium.wasm to render PDF files.
//

/**
 * PDFium WASM module imports
 */
const Pdfium = {
  /**
   * @param {WebAssembly.Exports} wasmExports
   */
  initWith: function (wasmExports) {
    Pdfium.wasmExports = wasmExports;
    Pdfium.memory = Pdfium.wasmExports.memory;
    Pdfium.wasmTable = Pdfium.wasmExports['__indirect_function_table'];
    Pdfium.stackSave = Pdfium.wasmExports['emscripten_stack_get_current'];
    Pdfium.stackRestore = Pdfium.wasmExports['_emscripten_stack_restore'];
    Pdfium.setThrew = Pdfium.wasmExports['setThrew'];
    Pdfium.__emscripten_stack_alloc = wasmExports['_emscripten_stack_alloc'];
  },

  /**
   * @type {WebAssembly.Exports}
   */
  wasmExports: null,
  /**
   * @type {WebAssembly.Memory}
   */
  memory: null,
  /**
   * @type {WebAssembly.Table}
   */
  wasmTable: null,
  /**
   * @type {WebAssembly.Table}
   */
  wasmTableMirror: [],
  /**
   * @type {WeakMap<Function, number>}
   */
  functionsInTableMap: null,
  /**
   * @type {number[]}
   */
  freeTableIndexes: [],
  /**
   * @type {function():number}
   */
  stackSave: null,
  /**
   * @type {function(number):void}
   */
  stackRestore: null,
  /**
   * @type {function(number, number):void}
   */
  setThrew: null,
  /**
   * @type {function(number):number}
   */
  __emscripten_stack_alloc: null,

  /**
   * Invoke a function from the WASM table
   * @param {number} index Function index
   * @param {function(function())} func Function to call
   * @returns {*} Result of the function
   */
  invokeFunc: function (index, func) {
    const sp = Pdfium.stackSave();
    try {
      return func(Pdfium.wasmTable.get(index));
    } catch (e) {
      Pdfium.stackRestore(sp);
      if (e !== e + 0) throw e;
      Pdfium.setThrew(1, 0);
    }
  },

  getCFunc: (ident) => Pdfium.wasmExports['_' + ident],
  writeArrayToMemory: (array, buffer) => HEAP8.set(array, buffer),
  stackAlloc: (sz) => Pdfium.__emscripten_stack_alloc(sz),
  stringToUTF8OnStack: (str) => {
    const size = StringUtils.lengthBytesUTF8(str) + 1;
    const ret = Pdfium.stackAlloc(size);
    StringUtils.stringToUtf8Bytes(str, ret);
    return ret;
  },
  ccall: (ident, returnType, argTypes, args, opts) => {
    const toC = {
      string: (str) => {
        let ret = 0;
        if (str !== null && str !== undefined && str !== 0) {
          ret = Pdfium.stringToUTF8OnStack(str);
        }
        return ret;
      },
      array: (arr) => {
        const ret = Pdfium.stackAlloc(arr.length);
        Pdfium.writeArrayToMemory(arr, ret);
        return ret;
      },
    };
    function convertReturnValue(ret) {
      if (returnType === 'string') return UTF8ToString(ret);
      if (returnType === 'boolean') return Boolean(ret);
      return ret;
    }
    const func = Pdfium.getCFunc(ident);
    const cArgs = [];
    let stack = 0;
    if (args) {
      for (let i = 0; i < args.length; i++) {
        const converter = toC[argTypes[i]];
        if (converter) {
          if (stack === 0) stack = Pdfium.stackSave();
          cArgs[i] = converter(args[i]);
        } else {
          cArgs[i] = args[i];
        }
      }
    }
    let ret = func(...cArgs);
    function onDone(ret) {
      if (stack !== 0) Pdfium.stackRestore(stack);
      return convertReturnValue(ret);
    }
    ret = onDone(ret);
    return ret;
  },
  cwrap: (ident, returnType, argTypes, opts) => {
    const numericArgs = !argTypes || argTypes.every((type) => type === 'number' || type === 'boolean');
    const numericRet = returnType !== 'string';
    if (numericRet && numericArgs && !opts) {
      return Pdfium.getCFunc(ident);
    }
    return (...args) => Pdfium.ccall(ident, returnType, argTypes, args, opts);
  },
  uleb128Encode: (n, target) => {
    if (n < 128) {
      target.push(n);
    } else {
      target.push(n % 128 | 128, n >> 7);
    }
  },
  sigToWasmTypes: (sig) => {
    const typeNames = {
      i: 'i32',
      j: 'i64',
      f: 'f32',
      d: 'f64',
      e: 'externref',
      p: 'i32',
    };
    const type = {
      parameters: [],
      results: sig[0] == 'v' ? [] : [typeNames[sig[0]]],
    };
    for (let i = 1; i < sig.length; ++i) {
      type.parameters.push(typeNames[sig[i]]);
    }
    return type;
  },
  generateFuncType: (sig, target) => {
    const sigRet = sig.slice(0, 1);
    const sigParam = sig.slice(1);
    const typeCodes = { i: 127, p: 127, j: 126, f: 125, d: 124, e: 111 };
    target.push(96);
    Pdfium.uleb128Encode(sigParam.length, target);
    for (let i = 0; i < sigParam.length; ++i) {
      target.push(typeCodes[sigParam[i]]);
    }
    if (sigRet == 'v') {
      target.push(0);
    } else {
      target.push(1, typeCodes[sigRet]);
    }
  },
  convertJsFunctionToWasm: (func, sig) => {
    if (typeof WebAssembly.Function == 'function') {
      return new WebAssembly.Function(Pdfium.sigToWasmTypes(sig), func);
    }
    const typeSectionBody = [1];
    Pdfium.generateFuncType(sig, typeSectionBody);
    const bytes = [0, 97, 115, 109, 1, 0, 0, 0, 1];
    Pdfium.uleb128Encode(typeSectionBody.length, bytes);
    bytes.push(...typeSectionBody);
    bytes.push(2, 7, 1, 1, 101, 1, 102, 0, 0, 7, 5, 1, 1, 102, 0, 0);
    const module = new WebAssembly.Module(new Uint8Array(bytes));
    const instance = new WebAssembly.Instance(module, { e: { f: func } });
    const wrappedFunc = instance.exports['f'];
    return wrappedFunc;
  },
  updateTableMap: (offset, count) => {
    if (Pdfium.functionsInTableMap) {
      for (let i = offset; i < offset + count; i++) {
        const item = Pdfium.wasmTable.get(i);
        if (item) {
          Pdfium.functionsInTableMap.set(item, i);
        }
      }
    }
  },
  getFunctionAddress: (func) => {
    if (!Pdfium.functionsInTableMap) {
      Pdfium.functionsInTableMap = new WeakMap();
      Pdfium.updateTableMap(0, Pdfium.wasmTable.length);
    }
    return Pdfium.functionsInTableMap.get(func) || 0;
  },
  getEmptyTableSlot: () => {
    if (Pdfium.freeTableIndexes.length) return Pdfium.freeTableIndexes.pop();
    try {
      Pdfium.wasmTable.grow(1);
    } catch (err) {
      if (!(err instanceof RangeError)) {
        throw err;
      }
      throw 'Unable to grow wasm table. Set ALLOW_TABLE_GROWTH.';
    }
    return Pdfium.wasmTable.length - 1;
  },
  /**
   * @param {function} func Function to add
   * @param {string} sig Signature of the function
   * @return {number} Function index in the table
   */
  addFunction: (func, sig) => {
    const rtn = Pdfium.getFunctionAddress(func);
    if (rtn) {
      return rtn;
    }
    const ret = Pdfium.getEmptyTableSlot();
    try {
      Pdfium.wasmTable.set(ret, func);
    } catch (err) {
      if (!(err instanceof TypeError)) {
        throw err;
      }
      const wrapped = Pdfium.convertJsFunctionToWasm(func, sig);
      Pdfium.wasmTable.set(ret, wrapped);
    }
    Pdfium.functionsInTableMap.set(func, ret);
    return ret;
  },
  removeFunction: (index) => {
    Pdfium.functionsInTableMap.delete(Pdfium.wasmTable.get(index));
    Pdfium.wasmTable.set(index, null);
    Pdfium.freeTableIndexes.push(index);
  },
};

/**
 * @typedef {Object} FileContext Defines I/O functions for a file
 * @property {number} size File size
 * @property {function(FileDescriptorContext, Uint8Array):number} read read(context, data)
 * @property {function(FileDescriptorContext):void|undefined} close close(context)
 * @property {function(FileDescriptorContext, Uint8Array):number|undefined} write write(context, data)
 * @property {function(FileDescriptorContext):number|undefined} sync sync(context)
 */

/**
 * @typedef {Object} FileDescriptorContext Defines I/O functions for a file descriptor
 * @property {number} size File size
 * @property {function(FileDescriptorContext, Uint8Array):number} read read(context, data)
 * @property {function(FileDescriptorContext):void|undefined} close close(context)
 * @property {function(FileDescriptorContext, Uint8Array):number|undefined} write write(context, data)
 * @property {function(FileDescriptorContext):number|undefined} sync sync(context)
 * @property {string} fileName
 * @property {number} fd
 * @property {number} flags
 * @property {number} mode
 * @property {number} dirfd
 * @property {number} position Current position
 */

/**
 * @typedef {Object} DirectoryContext Defines I/O functions for a directory file descriptor
 * @property {string[]} entries Directory entries (For directories, the name should be terminated with /)
 */

/**
 * @typedef {Object} DirectoryFileDescriptorContext Defines I/O functions for a directory file descriptor
 * @property {string[]} entries Directory entries (For directories, the name should be terminated with /)
 * @property {string} fileName
 * @property {number} fd
 * @property {number} dirfd
 * @property {number} position Current entry index
 */

/**
 * Emulate file system for PDFium
 */
class FileSystemEmulator {
  constructor() {
    /**
     * Filename to I/O functions/data
     * @type {Object<string, FileContext|DirectoryContext>}
     */
    this.fn2context = {};
    /**
     * File descriptor to I/O functions/data
     * @type {Object<number, FileDescriptorContext|DirectoryFileDescriptorContext>}
     */
    this.fd2context = {};
    /**
     * Last assigned file descriptor
     * @type {number}
     */
    this.fdAssignedLast = 1000;
  }

  /**
   * Register file
   * @param {string} fn Filename
   * @param {FileContext|DirectoryContext} context I/O functions/data
   */
  registerFile(fn, context) {
    this.fn2context[fn] = context;
  }

  /**
   * Register file with ArrayBuffer
   * @param {string} fn Filename
   * @param {ArrayBuffer} data File data
   */
  registerFileWithData(fn, data) {
    data = data.buffer != null ? data.buffer : data;
    this.registerFile(fn, {
      size: data.byteLength,
      read: function (context, buffer) {
        try {
          const size = Math.min(buffer.byteLength, data.byteLength - context.position);
          const array = new Uint8Array(data, context.position, size);
          buffer.set(array);
          context.position += array.byteLength;
          return array.length;
        } catch (err) {
          console.error(`read error: ${_error(err)}`);
          return 0;
        }
      },
    });
  }

  /**
   * Unregister file/directory context
   * @param {string} fn Filename
   */
  unregisterFile(fn) {
    delete this.fn2context[fn];
  }

  /**
   * Open a file
   * @param {number} dirfd Directory file descriptor
   * @param {number} fileNamePtr Pointer to buffer that contains filename
   * @param {number} flags File open flags
   * @param {number} mode File open mode
   * @returns {number} File descriptor
   */
  openFile(dirfd, fileNamePtr, flags, mode) {
    const fn = StringUtils.utf8BytesToString(new Uint8Array(Pdfium.memory.buffer, fileNamePtr, 2048));
    const funcs = this.fn2context[fn];
    if (funcs) {
      const fd = ++this.fdAssignedLast;
      this.fd2context[fd] = { ...funcs, fd, flags, mode, dirfd, position: 0 };
      return fd;
    }
    console.error(`openFile: not found: ${dirfd}/${fn}`);
    return -1;
  }

  /**
   * Close a file
   * @param {number} fd File descriptor
   */
  closeFile(fd) {
    const context = this.fd2context[fd];
    context.close?.call(context);
    delete this.fd2context[fd];
    return 0;
  }

  /**
   * Seek to a position in a file
   * @param {number} fd File descriptor
   * @returns {number} New offset
   */
  seek(fd) {
    let offset, whence, newOffset;
    if (arguments.length == 4) {
      // (fd: number, offset: BigInt, whence: number, newOffset: number)
      offset = Number(arguments[1]); // BigInt to Number
      whence = arguments[2];
      newOffset = arguments[3];
    } else if (arguments.length == 5) {
      // (fd: number, offset_low: number, offset_high: number, whence: number, newOffset: number)
      offset = arguments[1]; // offset_low; offset_high is ignored
      whence = arguments[3];
      newOffset = arguments[4];
    } else {
      throw new Error(`seek: invalid arguments count: ${arguments.length}`);
    }

    const context = this.fd2context[fd];
    switch (whence) {
      case 0: // SEEK_SET
        context.position = offset;
        break;
      case 1: // SEEK_CUR
        context.position += offset;
        break;
      case 2: // SEEK_END
        context.position = context.size + offset;
        break;
    }
    const offsetLowHigh = new Uint32Array(Pdfium.memory.buffer, newOffset, 2);
    offsetLowHigh[0] = context.position;
    offsetLowHigh[1] = 0;
    return 0;
  }

  /**
   * fd__write
   * @param {num} fd
   * @param {num} iovs
   * @param {num} iovs_len
   * @param {num} ret_ptr
   */
  write(fd, iovs, iovs_len, ret_ptr) {
    const context = this.fd2context[fd];
    let total = 0;
    for (let i = 0; i < iovs_len; i++) {
      const iov = new Int32Array(Pdfium.memory.buffer, iovs + i * 8, 2);
      const ptr = iov[0];
      const len = iov[1];
      const written = context.write(context, new Uint8Array(Pdfium.memory.buffer, ptr, len));
      total += written;
      if (written < len) break;
    }
    const bytes_written = new Uint32Array(Pdfium.memory.buffer, ret_ptr, 1);
    bytes_written[0] = written;
    return 0;
  }

  /**
   * fd_read
   * @param {num} fd
   * @param {num} iovs
   * @param {num} iovs_len
   * @param {num} ret_ptr
   */
  read(fd, iovs, iovs_len, ret_ptr) {
    /** @type {FileDescriptorContext} */
    const context = this.fd2context[fd];
    let total = 0;
    for (let i = 0; i < iovs_len; i++) {
      const iov = new Int32Array(Pdfium.memory.buffer, iovs + i * 8, 2);
      const ptr = iov[0];
      const len = iov[1];
      const read = context.read(context, new Uint8Array(Pdfium.memory.buffer, ptr, len));
      total += read;
      if (read < len) break;
    }
    const bytes_read = new Uint32Array(Pdfium.memory.buffer, ret_ptr, 1);
    bytes_read[0] = total;
    return 0;
  }

  sync(fd) {
    const context = this.fd2context[fd];
    return context.sync(context);
  }

  /**
   * __syscall_fstat64
   * @param {num} fd
   * @param {num} statbuf
   * @returns {num}
   */
  fstat(fd, statbuf) {
    const context = this.fd2context[fd];
    const buffer = new Int32Array(Pdfium.memory.buffer, statbuf, 92);
    buffer[6] = context.size; // st_size
    buffer[7] = 0;
    return 0;
  }

  /**
   * __syscall_stat64
   * @param {num} pathnamePtr
   * @param {num} statbuf
   * @returns {num}
   */
  stat64(pathnamePtr, statbuf) {
    const fn = StringUtils.utf8BytesToString(new Uint8Array(Pdfium.memory.buffer, pathnamePtr, 2048));
    const funcs = this.fn2context[fn];
    if (funcs) {
      const buffer = new Int32Array(Pdfium.memory.buffer, statbuf, 92);
      buffer[6] = funcs.size; // st_size
      buffer[7] = 0;
      return 0;
    }
    return -1;
  }

  /**
   * __syscall_getdents64
   * @param {num} fd
   * @param {num} dirp struct linux_dirent64
   * @param {num} count
   * @returns {num}
   */
  getdents64(fd, dirp, count) {
    /** @type {DirectoryFileDescriptorContext} */
    const context = this.fd2context[fd];
    const entries = context.entries;
    if (entries == null) return -1; // not a directory
    context.getdents_position = context.getdents_position || 0;
    let written = 0;
    const DT_REG = 8,
      DT_DIR = 4;
    _memset(dirp, 0, count);
    for (; context.position < entries.length; context.position++) {
      const i = context.position;
      let d_type, d_name;
      if (entries[i].endsWith('/')) {
        d_type = DT_DIR;
        d_name = entries[i].substring(0, entries[i].length - 1);
      } else {
        d_type = DT_REG;
        d_name = entries[i];
      }
      const d_nameLength = StringUtils.lengthBytesUTF8(d_name) + 1;
      const size = 8 + 8 + 2 + 1 + d_nameLength;
      if (written + size > count) break;

      const buffer = new Uint8Array(Pdfium.memory.buffer, dirp + written, size);
      // d_off
      const d_off = written + size;
      buffer[8] = d_off & 255;
      buffer[9] = (d_off >> 8) & 255;
      buffer[10] = (d_off >> 16) & 255;
      buffer[11] = (d_off >> 24) & 255;
      // d_reclen
      buffer[16] = size & 255;
      buffer[17] = (size >> 8) & 255;
      // d_type
      buffer[18] = d_type;
      // d_name
      StringUtils.stringToUtf8Bytes(d_name, new Uint8Array(Pdfium.memory.buffer, dirp + written + 19, d_nameLength));
      written = d_off;
    }
    return written;
  }
}

function _error(e) {
  return e.stack ? e.stack.toString() : e.toString();
}

function _notImplemented(name) {
  throw new Error(`${name} is not implemented`);
}

const fileSystem = new FileSystemEmulator();

const emEnv = {
  __assert_fail: function (condition, filename, line, func) {
    throw new Error(`Assertion failed: ${condition} at ${filename}:${line} (${func})`);
  },
  _emscripten_memcpy_js: function (dest, src, num) {
    new Uint8Array(Pdfium.memory.buffer).copyWithin(dest, src, src + num);
  },
  __syscall_openat: fileSystem.openFile.bind(fileSystem),
  __syscall_fstat64: fileSystem.fstat.bind(fileSystem),
  __syscall_ftruncate64: function (fd, zero, zero2, zero3) {
    _notImplemented('__syscall_ftruncate64');
  },
  __syscall_stat64: fileSystem.stat64.bind(fileSystem),
  __syscall_newfstatat: function (dirfd, pathnamePtr, statbuf, flags) {
    _notImplemented('__syscall_newfstatat');
  },
  __syscall_lstat64: function (pathnamePtr, statbuf) {
    _notImplemented('__syscall_lstat64');
  },
  __syscall_fcntl64: function (fd, cmd, arg) {
    _notImplemented('__syscall_fcntl64');
  },
  __syscall_ioctl: function (fd, request, arg) {
    _notImplemented('__syscall_ioctl');
  },
  __syscall_getdents64: fileSystem.getdents64.bind(fileSystem),
  __syscall_unlinkat: function (dirfd, pathnamePtr, flags) {
    _notImplemented('__syscall_unlinkat');
  },
  __syscall_rmdir: function (pathnamePtr) {
    _notImplemented('__syscall_rmdir');
  },
  _abort_js: function (what) {
    throw new Error(what);
  },
  _emscripten_throw_longjmp: function () {
    throw Infinity;
  },
  _gmtime_js: function (time, tmPtr) {
    time = Number(time);
    const date = new Date(time * 1000);
    const tm = new Int32Array(Pdfium.memory.buffer, tmPtr, 9);
    tm[0] = date.getUTCSeconds();
    tm[1] = date.getUTCMinutes();
    tm[2] = date.getUTCHours();
    tm[3] = date.getUTCDate();
    tm[4] = date.getUTCMonth();
    tm[5] = date.getUTCFullYear() - 1900;
    tm[6] = date.getUTCDay();
    tm[7] = 0; // dst
    tm[8] = 0; // gmtoff
  },
  _localtime_js: function (time, tmPtr) {
    _notImplemented('_localtime_js');
  },
  _tzset_js: function () {},
  emscripten_date_now: function () {
    return Date.now();
  },
  emscripten_errn: function () {
    _notImplemented('emscripten_errn');
  },
  emscripten_resize_heap: function (requestedSizeInBytes) {
    const maxHeapSizeInBytes = 2 * 1024 * 1024 * 1024; // 2GB
    if (requestedSizeInBytes > maxHeapSizeInBytes) {
      console.error(
        `emscripten_resize_heap: Cannot enlarge memory, asked for ${requestedPageCount} bytes but limit is ${maxHeapSizeInBytes}`
      );
      return false;
    }

    const pageSize = 65536;
    const oldPageCount = ((Pdfium.memory.buffer.byteLength + pageSize - 1) / pageSize) | 0;
    const requestedPageCount = ((requestedSizeInBytes + pageSize - 1) / pageSize) | 0;
    const newPageCount = Math.max(oldPageCount * 1.5, requestedPageCount) | 0;
    try {
      Pdfium.memory.grow(newPageCount - oldPageCount);
      console.log(`emscripten_resize_heap: ${oldPageCount} => ${newPageCount}`);
      return true;
    } catch (e) {
      console.error(`emscripten_resize_heap: Failed to resize heap: ${_error(e)}`);
      return false;
    }
  },
  exit: function (status) {
    _notImplemented('exit');
  },
  invoke_ii: function (index, a) {
    return Pdfium.invokeFunc(index, function (func) {
      return func(a);
    });
  },
  invoke_iii: function (index, a, b) {
    return Pdfium.invokeFunc(index, function (func) {
      return func(a, b);
    });
  },
  invoke_iiii: function (index, a, b, c) {
    return Pdfium.invokeFunc(index, function (func) {
      return func(a, b, c);
    });
  },
  invoke_iiiii: function (index, a, b, c, d) {
    return Pdfium.invokeFunc(index, function (func) {
      return func(a, b, c, d);
    });
  },
  invoke_v: function (index) {
    return Pdfium.invokeFunc(index, function (func) {
      func();
    });
  },
  invoke_viii: function (index, a, b, c) {
    Pdfium.invokeFunc(index, function (func) {
      func(a, b, c);
    });
  },
  invoke_viiii: function (index, a, b, c, d) {
    Pdfium.invokeFunc(index, function (func) {
      func(a, b, c, d);
    });
  },
  print: function (text) {
    console.log(text);
  },
  printErr: function (text) {
    console.error(text);
  },
};

const wasi = {
  proc_exit: function (code) {
    _notImplemented('proc_exit');
  },
  environ_sizes_get: function (environCount, environBufSize) {
    _notImplemented('environ_sizes_get');
  },
  environ_get: function (environ, environBuf) {
    _notImplemented('environ_get');
  },
  fd_close: fileSystem.closeFile.bind(fileSystem),
  fd_seek: fileSystem.seek.bind(fileSystem),
  fd_write: fileSystem.write.bind(fileSystem),
  fd_read: fileSystem.read.bind(fileSystem),
  fd_sync: fileSystem.sync.bind(fileSystem),
};

/**
 * @param {{url: string, password: string|undefined, useProgressiveLoading: boolean|undefined, headers: Object.<string, string>|undefined, withCredentials: boolean|undefined, progressCallbackId: number|undefined, preferRangeAccess: boolean|undefined}} params
 */
async function loadDocumentFromUrl(params) {
  const url = params.url;
  const password = params.password || '';
  const useProgressiveLoading = params.useProgressiveLoading || false;
  const headers = params.headers || {};
  const withCredentials = params.withCredentials || false;
  const progressCallbackId = params.progressCallbackId;

  const response = await fetch(url, {
    headers: headers,
    mode: 'cors',
    credentials: withCredentials ? 'include' : 'same-origin',
    redirect: 'follow',
  });
  const contentLength = parseInt(response.headers.get('content-length') || '0', 10);

  // If we have progress callback and a valid content length, use streaming
  if (progressCallbackId && contentLength > 0 && response.body) {
    const reader = response.body.getReader();
    const chunks = [];
    let receivedLength = 0;

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      chunks.push(value);
      receivedLength += value.length;

      // Send progress callback
      invokeCallback(progressCallbackId, receivedLength, contentLength);
    }

    // Combine chunks into single ArrayBuffer
    const data = new Uint8Array(receivedLength);
    let position = 0;
    for (const chunk of chunks) {
      data.set(chunk, position);
      position += chunk.length;
    }

    return loadDocumentFromData({
      data: data.buffer,
      password,
      useProgressiveLoading,
    });
  } else {
    // No progress callback or content-length, just get the data directly
    return loadDocumentFromData({
      data: await response.arrayBuffer(),
      password,
      useProgressiveLoading,
    });
  }
}

/**
 * @param {{data: ArrayBuffer, password: string|undefined, useProgressiveLoading: boolean|undefined}} params
 */
function loadDocumentFromData(params) {
  const data = params.data;
  const password = params.password || '';
  const useProgressiveLoading = params.useProgressiveLoading;

  const sizeThreshold = 1024 * 1024; // 1MB
  if (data.byteLength < sizeThreshold) {
    const buffer = Pdfium.wasmExports.malloc(data.byteLength);
    if (buffer === 0) {
      throw new Error('Failed to allocate memory for PDF data (${data.byteLength} bytes)');
    }
    new Uint8Array(Pdfium.memory.buffer, buffer, data.byteLength).set(new Uint8Array(data));
    const passwordPtr = StringUtils.allocateUTF8(password);
    const docHandle = Pdfium.wasmExports.FPDF_LoadMemDocument(buffer, data.byteLength, passwordPtr);
    StringUtils.freeUTF8(passwordPtr);
    return _loadDocument(docHandle, useProgressiveLoading, () => Pdfium.wasmExports.free(buffer));
  }

  const tempFileName = params.url ?? '/tmp/temp.pdf';
  fileSystem.registerFileWithData(tempFileName, data);

  const fileNamePtr = StringUtils.allocateUTF8(tempFileName);
  const passwordPtr = StringUtils.allocateUTF8(password);
  const docHandle = Pdfium.wasmExports.FPDF_LoadDocument(fileNamePtr, passwordPtr);
  StringUtils.freeUTF8(passwordPtr);
  StringUtils.freeUTF8(fileNamePtr);
  return _loadDocument(docHandle, useProgressiveLoading, () => fileSystem.unregisterFile(tempFileName));
}

/** @type {Object<number, function():void>} */
const disposers = {};

/** @typedef {{face: string, weight: number, italic: boolean, charset: number, pitch_family: number}} FontQuery
 * @typedef {Object<string, FontQuery>} FontQueries
 */
/** @type {FontQueries} */
let lastMissingFonts = {};

/** @type {Object<number, FontQueries>} */
let missingFonts = {};

/**
 *
 * @param {number} docHandle
 * @returns {FontQueries} Missing fonts new found.
 */
function _updateMissingFonts(docHandle) {
  if (Object.keys(lastMissingFonts).length === 0) return;

  const existing = missingFonts[docHandle] ?? {};
  missingFonts[docHandle] = { ...existing, ...lastMissingFonts };
  const result = lastMissingFonts;
  lastMissingFonts = {};
  return result;
}

function _resetMissingFonts() {
  missingFonts = {};
}

/**
 * @typedef {{docHandle: number,permissions: number, securityHandlerRevision: number, pages: PdfPage[], formHandle: number, formInfo: number, missingFonts: FontQueries}} PdfDocument
 * @typedef {{pageIndex: number, width: number, height: number, rotation: number, isLoaded: boolean, bbLeft: number, bbBottom: number}} PdfPage
 * @typedef {{errorCode: number, errorCodeStr: string|undefined, message: string}} PdfError
 */

/**
 * @param {number} docHandle
 * @param {boolean} useProgressiveLoading
 * @param {function():void} onDispose
 * @returns {PdfDocument|PdfError}
 */
function _loadDocument(docHandle, useProgressiveLoading, onDispose) {
  let formInfo = 0;
  let formHandle = 0;
  try {
    if (!docHandle) {
      const error = Pdfium.wasmExports.FPDF_GetLastError();
      const errorStr = _errorMappings[error];
      return {
        errorCode: error,
        errorCodeStr: _errorMappings[error],
        message: `Failed to load document`,
      };
    }

    missingFonts[docHandle] = {};
    lastMissingFonts = {};

    const pageCount = Pdfium.wasmExports.FPDF_GetPageCount(docHandle);
    const permissions = Pdfium.wasmExports.FPDF_GetDocPermissions(docHandle);
    const securityHandlerRevision = Pdfium.wasmExports.FPDF_GetSecurityHandlerRevision(docHandle);

    const formInfoSize = 35 * 4;
    formInfo = Pdfium.wasmExports.malloc(formInfoSize);
    const uint32 = new Uint32Array(Pdfium.memory.buffer, formInfo, formInfoSize >> 2);
    uint32[0] = 1; // version
    formHandle = Pdfium.wasmExports.FPDFDOC_InitFormFillEnvironment(docHandle, formInfo);

    const pages = _loadPagesInLimitedTime(docHandle, 0, useProgressiveLoading ? 1 : null);
    if (useProgressiveLoading) {
      const firstPage = pages[0];
      for (let i = 1; i < pageCount; i++) {
        pages.push({
          pageIndex: i,
          width: firstPage.width,
          height: firstPage.height,
          rotation: firstPage.rotation,
          isLoaded: false,
          bbLeft: 0,
          bbBottom: 0,
        });
      }
    }
    disposers[docHandle] = onDispose;
    _updateMissingFonts(docHandle);

    return {
      docHandle: docHandle,
      permissions: permissions,
      securityHandlerRevision: securityHandlerRevision,
      pages: pages,
      formHandle: formHandle,
      formInfo: formInfo,
      missingFonts: missingFonts[docHandle],
    };
  } catch (e) {
    try {
      if (formHandle !== 0) Pdfium.wasmExports.FPDFDOC_ExitFormFillEnvironment(formHandle);
    } catch (e) {}
    Pdfium.wasmExports.free(formInfo);
    delete disposers[docHandle];
    onDispose();
    throw e;
  }
}

/**
 * @param {number} docHandle
 * @param {number} pagesLoadedCountSoFar
 * @param {number|null} maxPageCountToLoadAdditionally
 * @param {number} timeoutMs
 * @returns {PdfPage[]}
 */
function _loadPagesInLimitedTime(docHandle, pagesLoadedCountSoFar, maxPageCountToLoadAdditionally, timeoutMs) {
  const pageCount = Pdfium.wasmExports.FPDF_GetPageCount(docHandle);
  const end =
    maxPageCountToLoadAdditionally == null
      ? pageCount
      : Math.min(pageCount, pagesLoadedCountSoFar + maxPageCountToLoadAdditionally);
  const t = timeoutMs != null ? Date.now() + timeoutMs : null;
  /** @type {PdfPage[]} */
  const pages = [];
  _resetMissingFonts();
  for (let i = pagesLoadedCountSoFar; i < end; i++) {
    const pageHandle = Pdfium.wasmExports.FPDF_LoadPage(docHandle, i);
    if (!pageHandle) {
      const error = Pdfium.wasmExports.FPDF_GetLastError();
      throw new Error(`FPDF_LoadPage failed (${_getErrorMessage(error)})`);
    }

  const rectBuffer = Pdfium.wasmExports.malloc(4 * 4); // FS_RECTF: float[4]
  Pdfium.wasmExports.FPDF_GetPageBoundingBox(pageHandle, rectBuffer);
  const rect = new Float32Array(Pdfium.memory.buffer, rectBuffer, 4);
  const bbLeft = rect[0];
  const bbBottom = rect[3];
  Pdfium.wasmExports.free(rectBuffer);

    pages.push({
      pageIndex: i,
      width: Pdfium.wasmExports.FPDF_GetPageWidthF(pageHandle),
      height: Pdfium.wasmExports.FPDF_GetPageHeightF(pageHandle),
      rotation: Pdfium.wasmExports.FPDFPage_GetRotation(pageHandle),
      isLoaded: true,
      bbLeft: bbLeft,
      bbBottom: bbBottom,
    });
    Pdfium.wasmExports.FPDF_ClosePage(pageHandle);
    if (t != null && Date.now() > t) {
      break;
    }
  }
  _updateMissingFonts(docHandle);
  return pages;
}

/**
 * @param {{docHandle: number, loadUnitDuration: number}} params
 * @returns {{pages: PdfPage[], missingFonts: FontQueries}}
 */
function loadPagesProgressively(params) {
  const { docHandle, firstPageIndex, loadUnitDuration } = params;
  const pages = _loadPagesInLimitedTime(docHandle, firstPageIndex, null, loadUnitDuration);
  return { pages, missingFonts: missingFonts[docHandle] };
}

/**
 * @param {{formHandle: number, formInfo: number, docHandle: number}} params
 */
function closeDocument(params) {
  if (params.formHandle) {
    try {
      Pdfium.wasmExports.FPDFDOC_ExitFormFillEnvironment(params.formHandle);
    } catch (e) {}
  }
  Pdfium.wasmExports.free(params.formInfo);
  Pdfium.wasmExports.FPDF_CloseDocument(params.docHandle);
  disposers[params.docHandle]();
  delete disposers[params.docHandle];
  delete missingFonts[params.docHandle];
  return { message: 'Document closed' };
}

/**
 * @typedef {{pageIndex: number, command: string, params: number[]}} PdfDest
 * @typedef {{title: string, dest: PdfDest, children: OutlineNode[]}} OutlineNode
 */

/**
 * @param {{docHandle: number}} params
 * @return {OutlineNode[]}
 */
function loadOutline(params) {
  return {
    outline: _getOutlineNodeSiblings(
      Pdfium.wasmExports.FPDFBookmark_GetFirstChild(params.docHandle, null),
      params.docHandle
    ),
  };
}

/**
 * @param {number} bookmark
 * @param {number} docHandle
 * @return {OutlineNode[]}
 */
function _getOutlineNodeSiblings(bookmark, docHandle) {
  /** @type {OutlineNode[]} */
  const siblings = [];
  while (bookmark) {
    const titleBufSize = Pdfium.wasmExports.FPDFBookmark_GetTitle(bookmark, null, 0);
    const titleBuf = Pdfium.wasmExports.malloc(titleBufSize);
    Pdfium.wasmExports.FPDFBookmark_GetTitle(bookmark, titleBuf, titleBufSize);
    const title = StringUtils.utf16BytesToString(new Uint8Array(Pdfium.memory.buffer, titleBuf, titleBufSize));
    Pdfium.wasmExports.free(titleBuf);
    siblings.push({
      title: title,
      dest: _pdfDestFromDest(Pdfium.wasmExports.FPDFBookmark_GetDest(docHandle, bookmark), docHandle),
      children: _getOutlineNodeSiblings(Pdfium.wasmExports.FPDFBookmark_GetFirstChild(docHandle, bookmark), docHandle),
    });
    bookmark = Pdfium.wasmExports.FPDFBookmark_GetNextSibling(docHandle, bookmark);
  }
  return siblings;
}

/**
 * @param {{docHandle: number, pageIndex: number}} params
 * @return {number} Page handle
 */
function loadPage(params) {
  const pageHandle = Pdfium.wasmExports.FPDF_LoadPage(params.docHandle, params.pageIndex);
  if (!pageHandle) {
    throw new Error(`Failed to load page ${params.pageIndex} from document ${params.docHandle}`);
  }
  return { pageHandle: pageHandle };
}

/**
 * @param {{pageHandle: number}} params
 */
function closePage(params) {
  Pdfium.wasmExports.FPDF_ClosePage(params.pageHandle);
  return { message: 'Page closed' };
}

/**
 *
 * @param {{
 * docHandle: number,
 * pageIndex: number,
 * x: number,
 * y: number,
 * width: number,
 * height: number,
 * fullWidth: number,
 * fullHeight: number,
 * backgroundColor: number,
 * annotationRenderingMode: number,
 * flags: number,
 * formHandle: number
 * }} params
 * @returns {{
 * imageData: ArrayBuffer,
 * width: number,
 * height: number,
 * missingFonts: FontQueries
 * }}
 */
function renderPage(params) {
  const {
    docHandle,
    pageIndex,
    x = 0,
    y = 0,
    width = 800,
    height = 600,
    fullWidth = width,
    fullHeight = height,
    backgroundColor,
    annotationRenderingMode = 0,
    flags = 0,
    formHandle,
  } = params;

  let pageHandle = 0;
  let bufferPtr = 0;
  let bitmap = 0;

  try {
    _resetMissingFonts();
    pageHandle = Pdfium.wasmExports.FPDF_LoadPage(docHandle, pageIndex);
    if (!pageHandle) {
      throw new Error(`Failed to load page ${pageIndex} from document ${docHandle}`);
    }

    const bufferSize = width * height * 4;
    bufferPtr = Pdfium.wasmExports.malloc(bufferSize);
    if (!bufferPtr) {
      throw new Error('Failed to allocate memory for rendering');
    }
    const FPDFBitmap_BGRA = 4;
    bitmap = Pdfium.wasmExports.FPDFBitmap_CreateEx(width, height, FPDFBitmap_BGRA, bufferPtr, width * 4);
    if (!bitmap) {
      throw new Error('Failed to create bitmap for rendering');
    }

    Pdfium.wasmExports.FPDFBitmap_FillRect(bitmap, 0, 0, width, height, backgroundColor);

    const FPDF_ANNOT = 1;
    const PdfAnnotationRenderingMode_none = 0;
    const PdfAnnotationRenderingMode_annotationAndForms = 2;
    const premultipliedAlpha = 0x80000000;

    const pdfiumFlags =
      (flags & 0xffff) | (annotationRenderingMode !== PdfAnnotationRenderingMode_none ? FPDF_ANNOT : 0);
    Pdfium.wasmExports.FPDF_RenderPageBitmap(bitmap, pageHandle, -x, -y, fullWidth, fullHeight, 0, pdfiumFlags);

    if (formHandle && annotationRenderingMode == PdfAnnotationRenderingMode_annotationAndForms) {
      Pdfium.wasmExports.FPDF_FFLDraw(formHandle, bitmap, pageHandle, -x, -y, fullWidth, fullHeight, 0, flags);
    }
    const src = new Uint8Array(Pdfium.memory.buffer, bufferPtr, bufferSize);
    let copiedBuffer = new ArrayBuffer(bufferSize);
    let dest = new Uint8Array(copiedBuffer);
    if (flags & premultipliedAlpha) {
      for (let i = 0; i < src.length; i += 4) {
        const a = src[i + 3];
        dest[i] = (src[i] * a + 128) >> 8;
        dest[i + 1] = (src[i + 1] * a + 128) >> 8;
        dest[i + 2] = (src[i + 2] * a + 128) >> 8;
        dest[i + 3] = a;
      }
    } else {
      dest.set(src);
    }

    _updateMissingFonts(docHandle);

    return {
      result: {
        imageData: copiedBuffer,
        width: width,
        height: height,
        missingFonts: missingFonts[docHandle],
      },
      transfer: [copiedBuffer],
    };
  } finally {
    Pdfium.wasmExports.FPDF_ClosePage(pageHandle);
    Pdfium.wasmExports.FPDFBitmap_Destroy(bitmap);
    Pdfium.wasmExports.free(bufferPtr);
  }
}

function _memset(ptr, value, num) {
  const buffer = new Uint8Array(Pdfium.memory.buffer, ptr, num);
  for (let i = 0; i < num; i++) {
    buffer[i] = value;
  }
}

/**
 *
 * @param {{pageIndex: number, docHandle: number}} params
 * @returns {{fullText: string, missingFonts: FontQueries}}
 */
function loadText(params) {
  _resetMissingFonts();
  const { pageIndex, docHandle } = params;
  const pageHandle = Pdfium.wasmExports.FPDF_LoadPage(docHandle, pageIndex);
  const textPage = Pdfium.wasmExports.FPDFText_LoadPage(pageHandle);
  if (textPage == null) return { fullText: '' };

  const count = Pdfium.wasmExports.FPDFText_CountChars(textPage);
  let fullText = '';

  for (let i = 0; i < count; i++) {
    fullText += String.fromCodePoint(Pdfium.wasmExports.FPDFText_GetUnicode(textPage, i));
  }

  Pdfium.wasmExports.FPDFText_ClosePage(textPage);
  Pdfium.wasmExports.FPDF_ClosePage(pageHandle);

  _updateMissingFonts(docHandle);
  return { fullText, missingFonts: missingFonts[docHandle] };
}

/**
 *
 * @param {{pageIndex: number, docHandle: number}} params
 * @returns {{charRects: number[][]}}
 */
function loadTextCharRects(params) {
  const { pageIndex, docHandle } = params;
  const pageHandle = Pdfium.wasmExports.FPDF_LoadPage(docHandle, pageIndex);
  const textPage = Pdfium.wasmExports.FPDFText_LoadPage(pageHandle);
  if (textPage == null) return { charRects: [] };

  const rectBuffer = Pdfium.wasmExports.malloc(8 * 4); // double[4]
  const rect = new Float64Array(Pdfium.memory.buffer, rectBuffer, 4);
  const count = Pdfium.wasmExports.FPDFText_CountChars(textPage);
  let charRects = [];
  for (let i = 0; i < count; i++) {
    Pdfium.wasmExports.FPDFText_GetCharBox(
      textPage,
      i,
      rectBuffer, // L
      rectBuffer + 8 * 2, // R
      rectBuffer + 8 * 3, // B
      rectBuffer + 8 // T
    );
    charRects.push(Array.from(rect));
  }
  Pdfium.wasmExports.free(rectBuffer);

  Pdfium.wasmExports.FPDFText_ClosePage(textPage);
  Pdfium.wasmExports.FPDF_ClosePage(pageHandle);
  return { charRects };
}

/**
 * @typedef {{rects: number[][], dest: url: string}} PdfUrlLink
 * @typedef {{rects: number[][], dest: PdfDest}} PdfDestLink
 */

/**
 * @param {{docHandle: number, pageIndex: number, enableAutoLinkDetection: boolean}} params
 * @returns {{links: Array<PdfUrlLink|PdfDestLink>}}
 */
function loadLinks(params) {
  const links = [..._loadAnnotLinks(params), ...(params.enableAutoLinkDetection ? _loadWebLinks(params) : [])];
  return {
    links: links,
  };
}

/**
 * @param {{docHandle: number, pageIndex: number, enableAutoLinkDetection: boolean}} params
 * @returns {Array<PdfUrlLink>}
 */
function _loadWebLinks(params) {
  const { pageIndex, docHandle } = params;
  const pageHandle = Pdfium.wasmExports.FPDF_LoadPage(docHandle, pageIndex);
  const textPage = Pdfium.wasmExports.FPDFText_LoadPage(pageHandle);
  if (textPage == null) return [];
  const linkPage = Pdfium.wasmExports.FPDFLink_LoadWebLinks(textPage);
  if (linkPage == null) return [];

  const links = [];
  const count = Pdfium.wasmExports.FPDFLink_CountWebLinks(linkPage);
  const rectBuffer = Pdfium.wasmExports.malloc(8 * 4); // double[4]
  for (let i = 0; i < count; i++) {
    const rectCount = Pdfium.wasmExports.FPDFLink_CountRects(linkPage, i);
    const rects = [];
    for (let j = 0; j < rectCount; j++) {
      Pdfium.wasmExports.FPDFLink_GetRect(linkPage, i, j, rectBuffer, rectBuffer + 8, rectBuffer + 16, rectBuffer + 24);
      rects.push(Array.from(new Float64Array(Pdfium.memory.buffer, rectBuffer, 4)));
    }
    links.push({
      rects: rects,
      url: _getLinkUrl(linkPage, i),
    });
  }
  Pdfium.wasmExports.free(rectBuffer);
  Pdfium.wasmExports.FPDFLink_CloseWebLinks(linkPage);
  Pdfium.wasmExports.FPDFText_ClosePage(textPage);
  Pdfium.wasmExports.FPDF_ClosePage(pageHandle);
  return links;
}

/**
 * @param {number} linkPage
 * @param {number} linkIndex
 * @returns {string}
 */
function _getLinkUrl(linkPage, linkIndex) {
  const urlLength = Pdfium.wasmExports.FPDFLink_GetURL(linkPage, linkIndex, null, 0);
  const urlBuffer = Pdfium.wasmExports.malloc(urlLength * 2);
  Pdfium.wasmExports.FPDFLink_GetURL(linkPage, linkIndex, urlBuffer, urlLength);
  const url = StringUtils.utf16BytesToString(new Uint8Array(Pdfium.memory.buffer, urlBuffer, urlLength * 2));
  Pdfium.wasmExports.free(urlBuffer);
  return url;
}

/**
 * @param {{docHandle: number, pageIndex: number}} params
 * @returns {Array<PdfDestLink|PdfUrlLink>}
 */
function _loadAnnotLinks(params) {
  const { pageIndex, docHandle } = params;
  const pageHandle = Pdfium.wasmExports.FPDF_LoadPage(docHandle, pageIndex);
  const count = Pdfium.wasmExports.FPDFPage_GetAnnotCount(pageHandle);
  const rectF = Pdfium.wasmExports.malloc(4 * 4); // float[4]
  const links = [];
  for (let i = 0; i < count; i++) {
    const annot = Pdfium.wasmExports.FPDFPage_GetAnnot(pageHandle, i);
    Pdfium.wasmExports.FPDFAnnot_GetRect(annot, rectF);
    const [l, t, r, b] = new Float32Array(Pdfium.memory.buffer, rectF, 4);
    const rect = [l, t > b ? t : b, r, t > b ? b : t];
    const dest = _processAnnotDest(annot, docHandle);
    if (dest) {
      links.push({ rects: [rect], dest: _pdfDestFromDest(dest, docHandle) });
    } else {
      const url = _processAnnotLink(annot, docHandle);
      if (url) {
        links.push({ rects: [rect], url: url });
      }
    }
    Pdfium.wasmExports.FPDFPage_CloseAnnot(annot);
  }
  Pdfium.wasmExports.free(rectF);
  Pdfium.wasmExports.FPDF_ClosePage(pageHandle);
  return links;
}

/**
 *
 * @param {number} annot
 * @param {number} docHandle
 * @returns {number|null} Dest
 */
function _processAnnotDest(annot, docHandle) {
  const link = Pdfium.wasmExports.FPDFAnnot_GetLink(annot);

  // firstly check the direct dest
  const dest = Pdfium.wasmExports.FPDFLink_GetDest(docHandle, link);
  if (dest) return dest;

  const action = Pdfium.wasmExports.FPDFLink_GetAction(link);
  if (!action) return null;
  const PDFACTION_GOTO = 1;
  switch (Pdfium.wasmExports.FPDFAction_GetType(action)) {
    case PDFACTION_GOTO:
      return Pdfium.wasmExports.FPDFAction_GetDest(docHandle, action);
    default:
      return null;
  }
}

/**
 * @param {number} annot
 * @param {number} docHandle
 * @returns {string|null} URI
 */
function _processAnnotLink(annot, docHandle) {
  const link = Pdfium.wasmExports.FPDFAnnot_GetLink(annot);
  const action = Pdfium.wasmExports.FPDFLink_GetAction(link);
  if (!action) return null;
  const PDFACTION_URI = 3;
  switch (Pdfium.wasmExports.FPDFAction_GetType(action)) {
    case PDFACTION_URI:
      const size = Pdfium.wasmExports.FPDFAction_GetURIPath(docHandle, action, null, 0);
      const buf = Pdfium.wasmExports.malloc(size);
      Pdfium.wasmExports.FPDFAction_GetURIPath(docHandle, action, buf, size);
      const uri = StringUtils.utf8BytesToString(new Uint8Array(Pdfium.memory.buffer, buf, size));
      Pdfium.wasmExports.free(buf);
      return uri;
    default:
      return null;
  }
}

/// [PDF 32000-1:2008, 12.3.2.2 Explicit Destinations, Table 151](https://opensource.adobe.com/dc-acrobat-sdk-docs/pdfstandards/PDF32000_2008.pdf#page=374)
const pdfDestCommands = ['unknown', 'xyz', 'fit', 'fitH', 'fitV', 'fitR', 'fitB', 'fitBH', 'fitBV'];

/**
 * @param {number} dest
 * @param {number} docHandle
 * @returns {PdfDest|null}
 */
function _pdfDestFromDest(dest, docHandle) {
  if (dest === 0) return null;
  const buf = Pdfium.wasmExports.malloc(40);
  const pageIndex = Pdfium.wasmExports.FPDFDest_GetDestPageIndex(docHandle, dest);
  const type = Pdfium.wasmExports.FPDFDest_GetView(dest, buf, buf + 4);
  const [count] = new Int32Array(Pdfium.memory.buffer, buf, 1);
  const params = Array.from(new Float32Array(Pdfium.memory.buffer, buf + 4, count));
  Pdfium.wasmExports.free(buf);
  if (type !== 0) {
    return {
      pageIndex,
      command: pdfDestCommands[type],
      params,
    };
  }
  return null;
}

/**
 * Setup the system font info in PDFium.
 */
function _initializeFontEnvironment() {
  // kBase14FontNames
  const fontNamesToIgnore = {
    Courier: true,
    'Courier-Bold': true,
    'Courier-BoldOblique': true,
    'Courier-Oblique': true,
    Helvetica: true,
    'Helvetica-Bold': true,
    'Helvetica-BoldOblique': true,
    'Helvetica-Oblique': true,
    'Times-Roman': true,
    'Times-Bold': true,
    'Times-BoldItalic': true,
    'Times-Italic': true,
    Symbol: true,
    ZapfDingbats: true,
  };

  // load the default system font info and modify only MapFont (index=3) entry with our one, which
  // wraps the original function and adds our custom logic
  const sysFontInfoBuffer = Pdfium.wasmExports.FPDF_GetDefaultSystemFontInfo();
  const sysFontInfo = new Int32Array(Pdfium.memory.buffer, sysFontInfoBuffer, 9); // struct _FPDF_SYSFONTINFO

  // void* MapFont(
  //   struct _FPDF_SYSFONTINFO* pThis,
  //   int weight,
  //   FPDF_BOOL bItalic,
  //   int charset,
  //   int pitch_family,
  //   const char* face,
  //   FPDF_BOOL* bExact);
  const mapFont = sysFontInfo[3];
  sysFontInfo[3] = Pdfium.addFunction((pThis, weight, bItalic, charset, pitchFamily, face, bExact) => {
    const result = Pdfium.invokeFunc(mapFont, (func) =>
      func(sysFontInfoBuffer, weight, bItalic, charset, pitchFamily, face, bExact)
    );
    if (!result) {
      // the font face is missing
      const faceName = StringUtils.utf8BytesToString(new Uint8Array(Pdfium.memory.buffer, face));
      if (fontNamesToIgnore[faceName] || lastMissingFonts[faceName]) return 0;
      lastMissingFonts[faceName] = {
        face: faceName,
        weight: weight,
        italic: !!bItalic,
        charset: charset,
        pitchFamily: pitchFamily,
      };
    }
    return result;
  }, 'iiiiiiii');

  // when registering a new SetSystemFontInfo, the previous one is automatically released
  // and the only last one remains on memory
  Pdfium.wasmExports.FPDF_SetSystemFontInfo(sysFontInfoBuffer);
}

/**
 * Reload fonts in PDFium.
 *
 * The function is based on the fact that PDFium reloads all the fonts when FPDF_SetSystemFontInfo is called.
 */
function reloadFonts() {
  console.log('Reloading system fonts in PDFium...');
  _initializeFontEnvironment();
  return { message: 'Fonts reloaded' };
}
/**
 * @type {{[face: string]: string}}
 */
const fontFileNames = {};
let fontFilesId = 0;

/**
 * Add font data to the file system.
 * @param {{face: string, data: ArrayBuffer}} params
 */
function addFontData(params) {
  console.log(`Adding font data for face: ${params.face}`);
  const { face, data } = params;
  fontFileNames[face] ??= `font_${++fontFilesId}.ttf`;
  fileSystem.registerFileWithData(`/usr/share/fonts/${fontFileNames[face]}`, data);
  fileSystem.registerFile('/usr/share/fonts', { entries: Object.values(fontFileNames) });
  return { message: `Font ${face} added`, face: face, fileName: fontFileNames[face] };
}

function clearAllFontData() {
  console.log(`Clearing all font data`);
  for (const face in fontFileNames) {
    const fileName = fontFileNames[face];
    fileSystem.unregisterFile(`/usr/share/fonts/${fileName}`);
  }
  fileSystem.registerFile('/usr/share/fonts', { entries: [] });
  fontFileNames = {};
  return { message: 'All font data cleared' };
}

/**
 * Functions that can be called from the main thread
 */
const functions = {
  loadDocumentFromUrl,
  loadDocumentFromData,
  loadPagesProgressively,
  closeDocument,
  loadOutline,
  loadPage,
  closePage,
  renderPage,
  loadText,
  loadTextCharRects,
  loadLinks,
  reloadFonts,
  addFontData,
  clearAllFontData,
};

/**
 * Send a callback invocation message back to the client
 * @param {number} callbackId The callback ID to invoke
 * @param {*} args Arguments to pass to the callback
 */
function invokeCallback(callbackId, ...args) {
  if (callbackId) {
    postMessage({
      type: 'callback',
      callbackId: callbackId,
      args: args,
    });
  }
}

function handleRequest(data) {
  const { id, command, parameters = {} } = data;

  try {
    const result = functions[command](parameters);
    if (result instanceof Promise) {
      result
        .then((finalResult) => {
          if (finalResult.result != null && finalResult.transfer != null) {
            postMessage({ id, status: 'success', result: finalResult.result }, finalResult.transfer);
          } else {
            postMessage({ id, status: 'success', result: finalResult });
          }
        })
        .catch((err) => {
          postMessage({
            id,
            status: 'error',
            error: _error(err),
          });
        });
    } else {
      if (result.result != null && result.transfer != null) {
        postMessage({ id, status: 'success', result: result.result }, result.transfer);
      } else {
        postMessage({ id, status: 'success', result: result });
      }
    }
  } catch (err) {
    postMessage({
      id,
      status: 'error',
      error: _error(err),
    });
  }
}

let messagesBeforeInitialized = [];
let pdfiumInitialized = false;

console.log(`PDFium worker initialized: ${self.location.href}`);

/**
 * Initialize PDFium with optional authentication parameters
 * @param {Object} params - Initialization parameters
 * @param {boolean} params.withCredentials - Whether to include credentials in the fetch
 * @param {Object} params.headers - Additional headers for the fetch request
 */
async function initializePdfium(params = {}) {
  try {
    if (pdfiumInitialized) {
      // Hot-restart or such may call this multiple times, so we can skip re-initialization
      return;
    }

    console.log(`Loading PDFium WASM module from ${pdfiumWasmUrl}`);

    const fetchOptions = {
      credentials: params.withCredentials ? 'include' : 'same-origin',
    };

    if (params.headers) {
      fetchOptions.headers = params.headers;
    }

    const result = await WebAssembly.instantiateStreaming(fetch(pdfiumWasmUrl, fetchOptions), {
      env: emEnv,
      wasi_snapshot_preview1: wasi,
    });

    Pdfium.initWith(result.instance.exports);
    Pdfium.wasmExports.FPDF_InitLibrary();
    _initializeFontEnvironment();

    pdfiumInitialized = true;

    postMessage({ type: 'ready' });

    // Process queued messages
    messagesBeforeInitialized.forEach((event) => handleRequest(event.data));
    messagesBeforeInitialized = null;
  } catch (err) {
    console.error('Failed to load WASM module:', err);
    postMessage({ type: 'error', error: _error(err) });
    throw err;
  }
}

onmessage = function (e) {
  const data = e.data;

  // Handle init command
  if (data && data.command === 'init') {
    initializePdfium(data.parameters || {})
      .then(() => {
        postMessage({ id: data.id, status: 'success', result: {} });
      })
      .catch((err) => {
        postMessage({ id: data.id, status: 'error', error: _error(err) });
      });
    return;
  }

  if (data && data.id && data.command) {
    if (!pdfiumInitialized && messagesBeforeInitialized) {
      messagesBeforeInitialized.push(e);
      return;
    }
    handleRequest(data);
  } else {
    console.error('Received improperly formatted message:', data);
  }
};

const _errorMappings = {
  0: 'FPDF_ERR_SUCCESS',
  1: 'FPDF_ERR_UNKNOWN',
  2: 'FPDF_ERR_FILE',
  3: 'FPDF_ERR_FORMAT',
  4: 'FPDF_ERR_PASSWORD',
  5: 'FPDF_ERR_SECURITY',
  6: 'FPDF_ERR_PAGE',
  7: 'FPDF_ERR_XFALOAD',
  8: 'FPDF_ERR_XFALAYOUT',
};

function _getErrorMessage(errorCode) {
  const error = _errorMappings[errorCode];
  return error ? `${error} (${errorCode})` : `Unknown error (${errorCode})`;
}

/**
 * String utilities
 */
class StringUtils {
  /**
   * UTF-16 string to bytes
   * @param {number[]} buffer
   * @returns {string} Converted string
   */
  static utf16BytesToString(buffer) {
    let endPtr = 0;
    while (buffer[endPtr] || buffer[endPtr + 1]) endPtr += 2;
    const str = new TextDecoder('utf-16le').decode(new Uint8Array(buffer.buffer, buffer.byteOffset, endPtr));
    return str;
  }
  /**
   * UTF-8 bytes to string
   * @param {number[]} buffer
   * @returns {string} Converted string
   */
  static utf8BytesToString(buffer) {
    let endPtr = 0;
    while (buffer[endPtr] && !(endPtr >= buffer.length)) ++endPtr;

    let str = '';
    let idx = 0;
    while (idx < endPtr) {
      let u0 = buffer[idx++];
      if (!(u0 & 0x80)) {
        str += String.fromCharCode(u0);
        continue;
      }
      const u1 = buffer[idx++] & 63;
      if ((u0 & 0xe0) == 0xc0) {
        str += String.fromCharCode(((u0 & 31) << 6) | u1);
        continue;
      }
      const u2 = buffer[idx++] & 63;
      if ((u0 & 0xf0) == 0xe0) {
        u0 = ((u0 & 15) << 12) | (u1 << 6) | u2;
      } else {
        u0 = ((u0 & 7) << 18) | (u1 << 12) | (u2 << 6) | (buffer[idx++] & 63);
      }
      if (u0 < 0x10000) {
        str += String.fromCharCode(u0);
      } else {
        const ch = u0 - 0x10000;
        str += String.fromCharCode(0xd800 | (ch >> 10), 0xdc00 | (ch & 0x3ff));
      }
    }
    return str;
  }
  /**
   * String to UTF-8 bytes
   * @param {string} str
   * @param {number[]} buffer
   * @returns {number} Number of bytes written to the buffer
   */
  static stringToUtf8Bytes(str, buffer) {
    let idx = 0;
    for (let i = 0; i < str.length; ++i) {
      let u = str.charCodeAt(i);
      if (u >= 0xd800 && u <= 0xdfff) {
        const u1 = str.charCodeAt(++i);
        u = (0x10000 + ((u & 0x3ff) << 10)) | (u1 & 0x3ff);
      }
      if (u <= 0x7f) {
        buffer[idx++] = u;
      } else if (u <= 0x7ff) {
        buffer[idx++] = 0xc0 | (u >> 6);
        buffer[idx++] = 0x80 | (u & 63);
      } else if (u <= 0xffff) {
        buffer[idx++] = 0xe0 | (u >> 12);
        buffer[idx++] = 0x80 | ((u >> 6) & 63);
        buffer[idx++] = 0x80 | (u & 63);
      } else {
        buffer[idx++] = 0xf0 | (u >> 18);
        buffer[idx++] = 0x80 | ((u >> 12) & 63);
        buffer[idx++] = 0x80 | ((u >> 6) & 63);
        buffer[idx++] = 0x80 | (u & 63);
      }
    }
    buffer[idx++] = 0;
    return idx;
  }
  /**
   * Calculate length of UTF-8 string in bytes (it does not contain the terminating '\0' character)
   * @param {string} str String to calculate length
   * @returns {number} Number of bytes
   */
  static lengthBytesUTF8(str) {
    let len = 0;
    for (let i = 0; i < str.length; ++i) {
      let u = str.charCodeAt(i);
      if (u >= 0xd800 && u <= 0xdfff) {
        u = (0x10000 + ((u & 0x3ff) << 10)) | (str.charCodeAt(++i) & 0x3ff);
      }
      if (u <= 0x7f) len += 1;
      else if (u <= 0x7ff) len += 2;
      else if (u <= 0xffff) len += 3;
      else len += 4;
    }
    return len;
  }
  /**
   * Allocate memory for UTF-8 string
   * @param {string} str
   * @returns {number} Pointer to allocated buffer that contains UTF-8 string. The buffer should be released by calling [freeUTF8].
   */
  static allocateUTF8(str) {
    if (str == null) return 0;
    const size = this.lengthBytesUTF8(str) + 1;
    const ptr = Pdfium.wasmExports.malloc(size);
    this.stringToUtf8Bytes(str, new Uint8Array(Pdfium.memory.buffer, ptr, size));
    return ptr;
  }
  /**
   * Release memory allocated for UTF-8 string
   * @param {number} ptr Pointer to allocated buffer
   */
  static freeUTF8(ptr) {
    Pdfium.wasmExports.free(ptr);
  }
}
