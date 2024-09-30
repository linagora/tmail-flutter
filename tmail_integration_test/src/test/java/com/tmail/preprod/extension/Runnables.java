package com.tmail.preprod.extension;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

public class Runnables {
    public static void runParallel(Runnable... runnables) {
        Flux<Runnable> stream = Flux.just(runnables);
        runParallel(stream);
    }

    public static void runParallel(Flux<Runnable> runnables) {
        runnables
            .publishOn(Schedulers.boundedElastic())
            .parallel()
            .runOn(Schedulers.boundedElastic())
            .flatMap(runnable -> {
                runnable.run();
                return Mono.empty();
            })
            .sequential()
            .then()
            .block();
    }
}
