//
//  ZKPreviewController.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2020/5/7.
//

#import <QuickLook/QuickLook.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKPreviewItem : NSObject <QLPreviewItem>

+ (instancetype)itemWithURL:(NSURL *)URL title:(NSString *)title;

@property (nonatomic, strong) NSURL *previewItemURL;
@property (nonatomic, strong) NSString *previewItemTitle;

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
