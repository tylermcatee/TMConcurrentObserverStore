//
//  TMConcurrentObserverStore.m
//  TMConcurrentObserverStore
//
//  Created by Tyler McAtee on 11/11/16.
//  Copyright © 2016 McAtee. All rights reserved.
//

#import "TMConcurrentObserverStore.h"

@implementation TMConcurrentObserverStore {
    NSLock *_lock;
    NSPointerArray *_observers;
}

- (instancetype)init {
    return [self initWithServiceName:@"TMConcurrentObserverStore"];
}

- (instancetype)initWithServiceName:(NSString *)serviceName {
    if (self = [super init]) {
        _observers = [NSPointerArray weakObjectsPointerArray];
        _lock = [NSLock new];
        [_lock setName:serviceName];
    }
    return self;
}

- (void)_withLock:(dispatch_block_t)block {
    [_lock lock];
    block();
    [_lock unlock];
}

- (void)addObserver:(id)observer {
    NSAssert(observer, @"Observer cannot be nil");
    [self _withLock:^{
        [_observers addPointer:(__bridge void *)observer];
    }];
}

- (void)removeObserver:(id)observer {
    NSAssert(observer, @"Observer cannot be nil");
    [self _withLock:^{
        for (NSUInteger index = 0 ; index < [_observers count]; index++) {
            id existing = [_observers pointerAtIndex:index];
            if (observer == existing) {
                [_observers replacePointerAtIndex:index withPointer:nil];
                break;
            }
        }
        [_observers compact];
    }];
}

- (void)enumerateObserversWithBlock:(void (^)(id))callback {
    NSMutableArray *mutableCopy = [NSMutableArray new];
    [self _withLock:^{
        [_observers compact];
        for (NSUInteger index = 0; index < [_observers count]; index++) {
            __strong id observer = [_observers pointerAtIndex:index];
            if (observer) {
                [mutableCopy addObject:observer];
            }
        }
    }];
    
    NSArray *immutableCopy = [mutableCopy copy];
    for (id observer in immutableCopy) {
        if (observer) {
            callback(observer);
        }
    }
}

@end
