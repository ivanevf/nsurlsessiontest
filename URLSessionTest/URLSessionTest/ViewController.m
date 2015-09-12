#import "ViewController.h"

@interface View : UIView
@property(nonatomic, retain) UIButton *uploadButton;
@end

@implementation View

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_uploadButton setTitle:@"Start Upload" forState:UIControlStateNormal];
    [self addSubview:_uploadButton];
    self.backgroundColor = [UIColor whiteColor];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _uploadButton.frame = CGRectMake(0.0, 0.0, 100.0, 50.0);
  _uploadButton.center = self.center;
}

@end

@interface ViewController () <NSURLSessionDelegate, NSURLSessionTaskDelegate>
@end

@implementation ViewController {
  View *_view;
  NSURLSession *_session;
  NSURLSessionTask *_sessionTask;
  NSOperationQueue *_opQueue;
  NSURLSessionUploadTask *_uploadTask;
  NSString *_filePath;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _opQueue = [NSOperationQueue mainQueue];
    NSURLSessionConfiguration *config =
        [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"test.config"];
    _session =
        [NSURLSession
            sessionWithConfiguration:config
            delegate:self
            delegateQueue:_opQueue];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"baer" ofType:@"JPG"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = paths.firstObject;
    _filePath = [docPath stringByAppendingPathComponent:@"test.jpg"];
    NSError *error;
    NSLog(@"File location: %@", _filePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
      [[NSFileManager defaultManager] moveItemAtPath:bundlePath toPath:_filePath error:&error];
      if (error) {
        NSLog(@"Could not copy file. %@", error);
      }
    } else {
      NSLog(@"File already exists.");
    }
  }
  return self;
}

- (void)loadView {
  CGRect frame = [UIApplication sharedApplication].keyWindow.bounds;
  _view = [[View alloc] initWithFrame:frame];
  [_view.uploadButton addTarget:self
                         action:@selector(uploadTestFile)
               forControlEvents:UIControlEventTouchUpInside];
  self.view = _view;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)uploadTestFile {
  NSURL *url = [NSURL URLWithString:@"http://localhost:8000"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                     timeoutInterval:60.0];
  request.HTTPMethod = @"PUT";
  _sessionTask = [_session uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:_filePath]];
  NSLog(@"--- uploading ----");
  //_view.uploadButton.enabled = NO;
  [_sessionTask resume];
}

#pragma mark - Delegate Methods

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
  NSLog(@" ---- sent %@ bytes sent out of %@ ----", @(bytesSent), @(totalBytesExpectedToSend));
  [NSException raise:@"foo" format:@"bar"];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
  NSLog(@"URLSession:didBecomeInvalidWithError  ---  error %@", error);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
  NSLog(@"URLSession:task:didCompleteWithError  ---  error %@", error);
}

@end
