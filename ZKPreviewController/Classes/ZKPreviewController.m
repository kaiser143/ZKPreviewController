//
//  ZKPreviewController.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2020/5/7.
//

#import "ZKPreviewController.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>

static NSString *_KAIMD5StringFromNSString(NSString *string) {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([data bytes], (CC_LONG)[data length], digest);
    NSMutableString *result = [NSMutableString string];
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", (int)(digest[i])];
    }
    return [result copy];
}

static NSString *_KAILocalFilePathForURL(NSURL *URL) {
    NSString *fileExtension   = [URL pathExtension];
    NSString *hashedURLString = _KAIMD5StringFromNSString([URL absoluteString]);
    NSString *cacheDirectory  = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    cacheDirectory            = [cacheDirectory stringByAppendingPathComponent:@"com.kaiser.RemoteQuickLook"];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory] || !isDirectory) {
        NSError *error          = nil;
        BOOL isDirectoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
                                                            withIntermediateDirectories:YES
                                                                             attributes:nil
                                                                                  error:&error];
        if (!isDirectoryCreated) {
            NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                             reason:@"Failed to crate cache directory"
                                                           userInfo:@{NSUnderlyingErrorKey: error}];
            @throw exception;
        }
    }
    if (!fileExtension) fileExtension = [URL.absoluteString pathExtension];

    NSString *temporaryFilePath = [[cacheDirectory stringByAppendingPathComponent:hashedURLString] stringByAppendingPathExtension:fileExtension];
    return temporaryFilePath;
}

@implementation ZKPreviewItem

+ (instancetype)itemWithURL:(NSURL *)URL title:(NSString *)title {
    return [[self alloc] initWithURL:URL title:title];
}

- (instancetype)initWithURL:(NSURL *)URL title:(NSString *)title {
    self = [super init];
    if (self == nil) return nil;
    
    self.previewItemURL = URL;
    self.previewItemTitle = title;
    
    return self;
}

@end


@interface ZKPreviewController () <QLPreviewControllerDelegate, QLPreviewControllerDataSource>

@property(nonatomic, weak) id<QLPreviewControllerDataSource> actualDataSource;

@end

@implementation ZKPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    [self reloadData];
}

#pragma mark - :. QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.items.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    ZKPreviewItem *previewItemCopy = [self.items objectAtIndex:index];

    NSURL *originalURL = previewItemCopy.previewItemURL;
    if (!originalURL || [originalURL isFileURL])
        return previewItemCopy;

    // If it's a remote file, check cache
    NSString *localFilePath        = _KAILocalFilePathForURL(originalURL);
    previewItemCopy.previewItemURL = [NSURL fileURLWithPath:localFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath])
        return previewItemCopy;

    // If it's not a local file, put a placeholder instead
    __block NSInteger capturedIndex = index;
    __weak __typeof(self) weakSelf = self;
    NSURLRequest *request           = [NSURLRequest requestWithURL:originalURL];

    AFHTTPSessionManager *manager          = AFHTTPSessionManager.manager;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
        progress:nil
        destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
            return [NSURL fileURLWithPath:localFilePath];
        }
        completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (controller.currentPreviewItemIndex == capturedIndex) [controller refreshCurrentPreviewItem];
                });
            } else {
                if ([strongSelf.kai_delegate respondsToSelector:@selector(previewController:failedToLoadRemotePreviewItem:withError:)]) {
                    [strongSelf.kai_delegate previewController:strongSelf failedToLoadRemotePreviewItem:previewItemCopy withError:error];
                }
            }
        }];
    [downloadTask resume];

    return previewItemCopy;
}

- (void)setItems:(NSArray<ZKPreviewItem *> *)items {
    _items = items;
    [self reloadData];
}

@end
