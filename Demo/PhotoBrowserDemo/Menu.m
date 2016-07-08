//
//  Menu.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 21/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "Menu.h"
#import "SDImageCache.h"
#import "MWCommon.h"


@interface PhotoResponse : NSObject
@property (strong, nonatomic) NSString *ImageName;
@property (strong, nonatomic) NSString *ImageSrc;

@property (strong, nonatomic) NSString *UrlRewrite;
@property (strong, nonatomic) NSString *Pageview;
//Width Height Description
@property (strong, nonatomic) NSString *CreateTime;
@end

@implementation Menu
#define API_KEY @"1f5718c16a7fb3a5452f45193232"
#define PAGE_COUNT 100

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
		self.title = @"MWPhotoBrowser";
        
        // Clear cache for testing
        [[SDImageCache sharedImageCache] clearDisk];
        [[SDImageCache sharedImageCache] clearMemory];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Push", @"Modal", nil]];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        if (SYSTEM_VERSION_LESS_THAN(@"7")) {
            _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        }
#endif
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segmentChange) forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];
        self.navigationItem.rightBarButtonItem = item;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];

        [self loadAssets];
        
    }
    return self;
}

- (void)segmentChange {
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    // Test toolbar hiding
//    [self setToolbarItems: @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil]]];
//    [[self navigationController] setToolbarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
//    self.navigationController.navigationBar.translucent = NO;
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 7;
    @synchronized(_assets) {
        if (_assets.count) rows++;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Create
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = _segmentedControl.selectedSegmentIndex == 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

    // Configure
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"Xinh";
            cell.detailTextLabel.text = @"Beautiful girl";
            break;
        }
        case 1: {
            cell.textLabel.text = @"Funny";
            cell.detailTextLabel.text = @"funny photo from hai.kenh360.com";
            break;
        }
        case 2: {
            cell.textLabel.text = @"Wedding";
            cell.detailTextLabel.text = @"Memory life";
            break;
        }
        case 4: {
            cell.textLabel.text = @"Food";
            cell.detailTextLabel.text = @"Food receipt";
            break;
        }
        case 3: {
            cell.textLabel.text = @"BI";
            cell.detailTextLabel.text = @"My lovely son";
            break;
        }
            
        case 5: {
            cell.textLabel.text = @"Kenh360 news";
            cell.detailTextLabel.text = @"news from kenh360.com";
            break;
        }
        case 6: {
            cell.textLabel.text = @"Funny video";
            cell.detailTextLabel.text = @"Funny video";
            break;
        }
        case 7: {
            cell.textLabel.text = @"Library photos";
            cell.detailTextLabel.text = @"photos from device library";
            break;
        }
        default: break;
    }
    return cell;
	
}
#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSError *error;
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = YES;
    BOOL enableGrid = YES;
    BOOL startOnGrid = YES;
    switch (indexPath.row) {
            //xinh
        case 0:{// xinh
            
            // Photos
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://xinh.kenh360.com/ActionHandler.ashx?currentPage=0&pageSize=100&categoryId=1&userId=&orderBy=&ActionObject=examination&action=getListImageByPage"]];
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:nil
                                                             error:nil];
            
            NSArray *jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            //NSMutableArray *groups = [[NSMutableArray alloc] init];
            
            for ( int i = 0 ; i < jsonDataArray.count ; i++ )
            {
                
                NSString *src =[[jsonDataArray objectAtIndex:i] objectForKey:@"ImageSrc"];
                
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:src]];
                photo.caption = [[jsonDataArray objectAtIndex:i] objectForKey:@"Description"];
                
                [photos addObject:photo];
                [thumbs addObject:photo];
            }
            
            // Options
            displayActionButton = NO;
            displaySelectionButtons = NO;
            displayNavArrows = YES;
            startOnGrid = YES;
        }
            break;
            // funny
        case 1: {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://hai.kenh360.com/ActionHandler.ashx?currentPage=0&pageSize=100&categoryId=1&userId=&orderBy=&ActionObject=examination&action=getListImageByPage"]];
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:nil
                                                             error:nil];
            
            NSArray *jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            //NSMutableArray *groups = [[NSMutableArray alloc] init];
            
            for ( int i = 0 ; i < jsonDataArray.count ; i++ )
            {
                
                NSString *src =[[jsonDataArray objectAtIndex:i] objectForKey:@"ImageSrc"];
                
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:src]];
                photo.caption = [[jsonDataArray objectAtIndex:i] objectForKey:@"Description"];
                
                [photos addObject:photo];
                [thumbs addObject:photo];
            }
            
        }
            break;
            // wedding
        case 2: {
            // Photos
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://anhcuoi.kenh360.com/ActionHandler.ashx?currentPage=0&pageSize=100&categoryId=1&userId=&orderBy=&ActionObject=examination&action=getListImageByPage"]];
            /*
             __block NSDictionary *json;
             [NSURLConnection sendAsynchronousRequest:request
             queue:[NSOperationQueue mainQueue]
             completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             if (data.length > 0 && connectionError == nil)
             {
             json = [NSJSONSerialization JSONObjectWithData:data
             options:0
             error:nil];
             NSLog(@"Async JSON: %@", json);
             }
             }];
             */
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:nil
                            
                                                             error:nil];
            
            NSArray *jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            //NSMutableArray *groups = [[NSMutableArray alloc] init];
            
            for ( int i = 0 ; i < jsonDataArray.count ; i++ )
            {
                
                NSString *src = [NSString stringWithFormat:@"%@.400.400.cache", [[jsonDataArray objectAtIndex:i] objectForKey:@"ImageSrc"]];
                
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:src]];//+
                photo.caption = [[jsonDataArray objectAtIndex:i] objectForKey:@"Description"];
                
                [photos addObject:photo];
                [thumbs addObject:photo];
            }
            
            // Options
            displayActionButton = NO;
            displaySelectionButtons = NO;
            displayNavArrows = YES;
            startOnGrid = YES;
        }
            break;
            
        case 3://BI
        {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://beyeu.kenh360.com/ActionHandler.ashx?currentPage=0&pageSize=100&categoryId=1&userId=&orderBy=&ActionObject=examination&action=getListImageByPage"]];
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:nil
                            
                                                             error:nil];
            
            NSArray *jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            for ( int i = 0 ; i < jsonDataArray.count ; i++ )
            {
                
                NSString *src =[[jsonDataArray objectAtIndex:i] objectForKey:@"ImageSrc"];
                
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:src]];
                photo.caption = [[jsonDataArray objectAtIndex:i] objectForKey:@"Description"];
                
                [photos addObject:photo];
                [thumbs addObject:photo];
            }
        }
            break;
        case 4://Food
        {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.kenh360.com/blog/api/news?pageindex=1&pagesize=100"]];
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:nil
                            
                                                             error:nil];
            
            NSArray *jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            for ( int i = 0 ; i < jsonDataArray.count ; i++ )
            {
                
                NSString *src =[[jsonDataArray objectAtIndex:i] objectForKey:@"Thumb"];
                
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:src]];
                photo.caption = [[jsonDataArray objectAtIndex:i] objectForKey:@"Title"];
                
                [photos addObject:photo];
                [thumbs addObject:photo];
            }

            
        }
            break;
        case 5:// news
        {
            //
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.kenh360.com/news/api/news?pageindex=1&pagesize=100"]];
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:nil
                            
                                                             error:nil];
            
            NSArray *jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            for ( int i = 0 ; i < jsonDataArray.count ; i++ )
            {
                
                NSString *src =[[jsonDataArray objectAtIndex:i] objectForKey:@"Thumb"];
                
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:src]];
                photo.caption = [[jsonDataArray objectAtIndex:i] objectForKey:@"Title"];
                
                [photos addObject:photo];
                [thumbs addObject:photo];
            }
        }
            break;
            
        case 6:// video
        {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.kenh360.com/video/api/video?pageindex=1&pagesize=10"]];
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:nil
                            
                                                             error:nil];
            
            NSArray *jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            for ( int i = 0 ; i < jsonDataArray.count ; i++ )
            {
                
                NSString *src =[[jsonDataArray objectAtIndex:i] objectForKey:@"Thumb"];
                
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:src]];
                photo.caption = [[jsonDataArray objectAtIndex:i] objectForKey:@"Title"];
                
                [photos addObject:photo];
                [thumbs addObject:photo];
            }
        }
            break;
        case 7:// library
        {
            @synchronized(_assets) {
                NSMutableArray *copy = [_assets copy];
                for (ALAsset *asset in copy) {
                    [photos addObject:[MWPhoto photoWithURL:asset.defaultRepresentation.url]];
                    [thumbs addObject:[MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]]];
                }
            }
            break;
        }
        default: break;
    }
    self.photos = photos;
    self.thumbs = thumbs;
	
	// Create browser
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    // Show
    if (_segmentedControl.selectedSegmentIndex == 0) {
        // Push
        [self.navigationController pushViewController:browser animated:YES];
    } else {
        // Modal
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
    }
    
    // Release
	
	// Deselect
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
//        // Test removing an object
//        [_photos removeLastObject];
//        [browser reloadData];
//    
//        // Test all new
//        [_photos removeAllObjects];
//        [_photos addObject:[MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
//        [browser reloadData];
//    
//        // Test changing photo index
//        [browser setCurrentPhotoIndex:9];
    
//        // Test updating selections
//        _selections = [NSMutableArray new];
//        for (int i = 0; i < [self numberOfPhotosInPhotoBrowser:browser]; i++) {
//            [_selections addObject:[NSNumber numberWithBool:YES]];
//        }
//        [browser reloadData];
        
    });

}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Load Assets

- (void)loadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(_assets) {
                                               [_assets addObject:asset];
                                               if (_assets.count == 1) {
                                                   // Added first asset so reload data
                                                   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                               }
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      NSLog(@"operation was not successfull!");
                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                       }];
        
    });
    
}

@end

