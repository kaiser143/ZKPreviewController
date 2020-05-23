//
//  ZKPreviewController.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2020/5/7.
//

#import <QuickLook/QuickLook.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKPreviewItem : NSObject <QLPreviewItem>

+ (instancetype)itemWithURL:(NSURL *)URL title:(nullable NSString *)title;
+ (instancetype)itemWithURL:(NSURL *)URL title:(nullable NSString *)title filenameHashed:(BOOL)filenameHashed;

@property (nonatomic, strong, readonly) NSURL *previewItemURL;
@property (nonatomic, strong, readonly) NSString *previewItemTitle;

// default: YES(使用md5 url 作为文件名)
@property (nonatomic, assign, readonly) BOOL filenameHashed;

@end


@class ZKPreviewController;

@protocol ZKPreviewControllerDelegate <NSObject>

- (void)previewController:(ZKPreviewController *)controller failedToLoadRemotePreviewItem:(ZKPreviewItem *)previewItem withError:(NSError *)error;

@end

@interface ZKPreviewController : QLPreviewController

@property (nonatomic, strong) NSArray<ZKPreviewItem *> *items;
@property (nonatomic, weak) id<ZKPreviewControllerDelegate> kai_delegate;

@end

NS_ASSUME_NONNULL_END
