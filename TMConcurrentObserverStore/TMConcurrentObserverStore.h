//
//  TMConcurrentObserverStore.h
//  TMConcurrentObserverStore
//
//  Created by Tyler McAtee on 11/11/16.
//  Copyright © 2016 McAtee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMConcurrentObserverStore : NSObject

- (instancetype)init;
- (instancetype)initWithServiceName:(NSString *)serviceName;
- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;
- (void)enumerateObserversWithBlock:(void (^)(id observer))callback;

@end
