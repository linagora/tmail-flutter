const closeSmartBannerButton = document.querySelector('.smart-banner button.close');
if (closeSmartBannerButton) closeSmartBannerButton.addEventListener('click', closeSmartBanner);
const openTwakeMailAppButton = document.getElementById('open-button-id');
if (openTwakeMailAppButton) openTwakeMailAppButton.addEventListener('click', openTwakeMailApp);

    {{flutter_js}}
    {{flutter_build_config}}

    // currentScript is null inside the async loader callback below.
    var cspNonce = document.currentScript && document.currentScript.nonce;

    loadLanguageResources().finally(initialTmailApp);

    if ('serviceWorker' in navigator) {
      navigator
        .serviceWorker
        .getRegistrations()
        .then(async function(registrations) {
          try {
            await Promise.all(registrations.map(function(registration) {
              return registration.unregister();
            }));
          } catch (error) {
            console.log('[Twake Mail] Error unregistering service worker: ', error);
          }
          _flutter.loader.load({
            nonce: cspNonce,
            config: { nonce: cspNonce },
            onEntrypointLoaded: async function(engineInitializer) {
              const appRunner = await engineInitializer.initializeEngine({
                fontFallbackBaseUrl: '',
                nonce: cspNonce
              });
              await setTimeout( async function () {
                await appRunner.runApp();
              }, 2000);
            }
          });
        });
    } else {
      _flutter.loader.load({
        nonce: cspNonce,
        config: { nonce: cspNonce },
        onEntrypointLoaded: async function(engineInitializer) {
          const appRunner = await engineInitializer.initializeEngine({
            fontFallbackBaseUrl: '',
            nonce: cspNonce
          });
          await setTimeout( async function () {
            await appRunner.runApp();
          }, 2000);
        }
      });
    }
