//
//  main.m
//  FSEventExample
//
//  Created by Jonghoon Yoon on 8/3/19.
//  Copyright © 2019 Jonghoon Yoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

void printFlagDescription(FSEventStreamEventFlags flag) {
    if (flag == kFSEventStreamEventFlagNone) {
        printf(" - There was some change in the directory at the specific path");
    }
    if (flag & kFSEventStreamEventFlagMustScanSubDirs) {
        /*
         * Your application must rescan not just the directory given in the
         * event, but all its children, recursively. This can happen if there
         * was a problem whereby events were coalesced hierarchically. For
         * example, an event in /Users/jsmith/Music and an event in
         * /Users/jsmith/Pictures might be coalesced into an event with this
         * flag set and path=/Users/jsmith. If this flag is set you may be
         * able to get an idea of whether the bottleneck happened in the
         * kernel (less likely) or in your client (more likely) by checking
         * for the presence of the informational flags
         * kFSEventStreamEventFlagUserDropped or
         * kFSEventStreamEventFlagKernelDropped.
         */
        printf(" - MustScanSubDirs\n");
    }
    if (flag & kFSEventStreamEventFlagUserDropped || flag & kFSEventStreamEventFlagKernelDropped) {
        /*
         * The kFSEventStreamEventFlagUserDropped or
         * kFSEventStreamEventFlagKernelDropped flags may be set in addition
         * to the kFSEventStreamEventFlagMustScanSubDirs flag to indicate
         * that a problem occurred in buffering the events (the particular
         * flag set indicates where the problem occurred) and that the client
         * must do a full scan of any directories (and their subdirectories,
         * recursively) being monitored by this stream. If you asked to
         * monitor multiple paths with this stream then you will be notified
         * about all of them. Your code need only check for the
         * kFSEventStreamEventFlagMustScanSubDirs flag; these flags (if
         * present) only provide information to help you diagnose the problem.
         */
        printf(" - UserDropped or KernelDropped\n");
    }
    if (flag & kFSEventStreamEventFlagEventIdsWrapped) {
        /*
         * If kFSEventStreamEventFlagEventIdsWrapped is set, it means the
         * 64-bit event ID counter wrapped around. As a result,
         * previously-issued event ID's are no longer valid arguments for the
         * sinceWhen parameter of the FSEventStreamCreate...() functions.
         */
        printf(" - EventIdsWrapped\n");
    }
    if (flag & kFSEventStreamEventFlagHistoryDone) {
        /*
         * Denotes a sentinel event sent to mark the end of the "historical"
         * events sent as a result of specifying a sinceWhen value in the
         * FSEventStreamCreate...() call that created this event stream. (It
         * will not be sent if kFSEventStreamEventIdSinceNow was passed for
         * sinceWhen.) After invoking the client's callback with all the
         * "historical" events that occurred before now, the client's
         * callback will be invoked with an event where the
         * kFSEventStreamEventFlagHistoryDone flag is set. The client should
         * ignore the path supplied in this callback.
         */
        printf(" - HistoryDone\n");
    }
    if (flag & kFSEventStreamEventFlagRootChanged) {
        /*
         * Denotes a special event sent when there is a change to one of the
         * directories along the path to one of the directories you asked to
         * watch. When this flag is set, the event ID is zero and the path
         * corresponds to one of the paths you asked to watch (specifically,
         * the one that changed). The path may no longer exist because it or
         * one of its parents was deleted or renamed. Events with this flag
         * set will only be sent if you passed the flag
         * kFSEventStreamCreateFlagWatchRoot to FSEventStreamCreate...() when
         * you created the stream.
         */
        printf(" - RootChanged\n");
    }
    if (flag & kFSEventStreamEventFlagMount) {
        printf(" - is mounted\n");
    }
    if (flag & kFSEventStreamEventFlagUnmount) {
        printf(" - is unmounted\n");
    }
    
    /* This flags are only ever set if you specified the FileEvents flag when creating the stream. */
    if (flag & kFSEventStreamEventFlagItemCreated) {
        printf(" - file system object was created\n");
    }
    if (flag & kFSEventStreamEventFlagItemRemoved) {
        printf(" - file system object was removed\n");
    }
    if (flag & kFSEventStreamEventFlagItemInodeMetaMod) {
        printf(" - metadata modified\n");
    }
    if (flag & kFSEventStreamEventFlagItemRenamed) {
        printf(" - file system object was renamed\n");
    }
    if (flag & kFSEventStreamEventFlagItemModified) {
        printf(" - data modified\n");
    }
    if (flag & kFSEventStreamEventFlagItemFinderInfoMod) {
        printf(" - FinderInfo data modified\n");
    }
    if (flag & kFSEventStreamEventFlagItemChangeOwner) {
        printf(" - ownership changed\n");
    }
    if (flag & kFSEventStreamEventFlagItemXattrMod) {
        printf(" - extended attributes modified\n");
    }
    if (flag & kFSEventStreamEventFlagItemIsFile) {
        printf(" - is a regular file\n");
    }
    if (flag & kFSEventStreamEventFlagItemIsDir) {
        printf(" - is a directory\n");
    }
    if (flag & kFSEventStreamEventFlagItemIsSymlink) {
        printf(" - is a symbolic link\n");
    }
    if (flag & kFSEventStreamEventFlagItemIsHardlink) {
        printf(" - is a hard link\n");
    }
    if (flag & kFSEventStreamEventFlagItemIsLastHardlink) {
        printf(" - was the last hard link\n");
    }
    if (flag & kFSEventStreamEventFlagItemCloned) {
        printf(" - is a clone or was cloned\n");
    }
    
    /* This flag is only ever set if you specified the MarkSelf flag when creating the stream. */
    if (flag & kFSEventStreamEventFlagOwnEvent) {
        printf(" - Indicates the object at the specified path supplied in this event is a hard link.\n");
    }
}

void mycallback(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[])
{
    int i;
    char **paths = eventPaths;
    
    printf("-------------------------------------------------------------------\n");
    for (i=0; i<numEvents; i++) {
        /* flags are unsigned long, IDs are uint64_t */
        printf("Change %llu in %s, flags %u\n", eventIds[i], paths[i], eventFlags[i]);
        printFlagDescription(eventFlags[i]);
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /* Define variables and create a CFArray object containing
         CFString objects containing paths to watch.
         */
        CFStringRef mypath = CFSTR("/Users/jonghoon/Desktop/");
        CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
        void *callbackInfo = NULL; // could put stream-specific data here.
        FSEventStreamRef stream;
        CFAbsoluteTime latency = 1.0; /* Latency in seconds */
        
        /* Create the stream, passing in a callback */
        stream = FSEventStreamCreate(NULL,
                                     &mycallback,
                                     callbackInfo,
                                     pathsToWatch,
                                     kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                     latency,
                                     kFSEventStreamCreateFlagFileEvents /* Flags explained in reference */
                                     );
        
        /* Create the stream before calling this. */
        FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        FSEventStreamStart(stream);
        
        [NSRunLoop.currentRunLoop run];
    }
    return 0;
}
