//
//  IosExerciseTableViewController.m
//  IOS_Exercise
//
//  Created by LT-168-Ashwini Langde on 02/05/16.
//  Copyright © 2016 Ashwini Langde. All rights reserved.
//

#import "IosExerciseTableViewController.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

#define API_URL @"https://dl.dropboxusercontent.com/u/746330/facts.json"

#define TITLE_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]

#define DESCRIPTION_FONT [UIFont fontWithName:@"HelveticaNeue" size:12.0f]

@interface IosExerciseTableViewController ()

@end

@interface UIView (Autolayout)
+ (id)autolayoutView;
@end

@implementation UIView (Autolayout)
+ (id)autolayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}
@end

@implementation IosExerciseTableViewController{
    UITableView *_tableView;
    NSMutableArray *arrayFromJson;
    UIActivityIndicatorView *spinner;
    NSURLSession *session;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                       target:self action:@selector(refreshClicked:)] ;
    self.navigationItem.rightBarButtonItem = refreshButton;
    

    
    // init table view
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.estimatedRowHeight = 44.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    // add to canvas
    [self.view addSubview:_tableView];
    
    
    if(arrayFromJson == nil)
    {
        arrayFromJson = [[NSMutableArray alloc] init];
    }
    
    
    spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [self refreshData];
    
}



- (IBAction)refreshClicked:(id)sender {
    
    [self refreshData];
}

-(void)refreshData
{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //get the response of URL using CJSONDeserializer
        NSError *error;
        NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString: API_URL] encoding:NSISOLatin1StringEncoding error:&error];
        
        NSData *responseData = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *receivedDataDictionary = [[CJSONDeserializer deserializer] deserialize:responseData error:&error];
        
        if (error) {
            [spinner stopAnimating];
            //Error handling
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.navigationItem.title = [receivedDataDictionary objectForKey:@"title"];
                
                if([arrayFromJson count] > 0)
                {
                    [arrayFromJson removeAllObjects];
                }
                
                //use your json object
                arrayFromJson = [receivedDataDictionary objectForKey:@"rows"];
                
                
                [_tableView reloadData];
                if(spinner.isAnimating)
                {
                    [spinner stopAnimating];
                }
                
            });
        }

    });

    
    
    
    /*
    session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:string] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *receivedDataDictionary = [[CJSONDeserializer deserializer] deserialize:data error:&error];
        
        if (error) {
            //Error handling
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.navigationItem.title = [receivedDataDictionary objectForKey:@"title"];
                
               if([arrayFromJson count] > 0)
               {
                   [arrayFromJson removeAllObjects];
               }
                
                //use your json object
                arrayFromJson = [receivedDataDictionary objectForKey:@"rows"];
                
                
                [_tableView reloadData];
                
            });
        }

    }];
    
     [dataTask resume];
    */
    
  
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayFromJson count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

        //create a Heading label and add on table cell
        UILabel *headingLine = [UILabel autolayoutView];
        headingLine.font = TITLE_FONT;
        headingLine.numberOfLines = 0;
        headingLine.textColor = [UIColor blackColor];
        [cell addSubview:headingLine];
        
        //create a Description label and add on table cell
        UILabel *descriptionLine = [UILabel autolayoutView];
        descriptionLine.font = DESCRIPTION_FONT;
        descriptionLine.numberOfLines = 0;
        descriptionLine.textColor = [UIColor lightGrayColor];
        
        
        [cell addSubview:descriptionLine];
        
        //create a Imageview and add on table cell
        UIImageView *imageView = [UIImageView autolayoutView];
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        [cell addSubview:imageView];
        
        
        if([[arrayFromJson objectAtIndex:indexPath.row] objectForKey:@"title"] != [NSNull null])
        {
            headingLine.text = [[arrayFromJson objectAtIndex:indexPath.row] objectForKey:@"title"];
    
        }
        if([[arrayFromJson objectAtIndex:indexPath.row] objectForKey:@"imageHref"] != [NSNull null])
        {
    
            // Lazy image loaded
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *kitten = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[arrayFromJson objectAtIndex:indexPath.row] objectForKey:@"imageHref"]] options:0 error:nil]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = kitten;
                });
            });

        }
        if([[arrayFromJson objectAtIndex:indexPath.row] objectForKey:@"description"] != [NSNull null])
        {
            descriptionLine.text = [[arrayFromJson objectAtIndex:indexPath.row] objectForKey:@"description"];
        }
    
  
        NSDictionary *views = NSDictionaryOfVariableBindings(cell,headingLine,descriptionLine,imageView);
        
        
        // align view from the left and right
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageView]-[headingLine]-|" options:0 metrics:nil views:views]];
        
        
        // width constraint
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(==40)]" options:0 metrics:nil views:views]];
        
        // height constraint
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(==40)]" options:0 metrics:nil views:views]];
        
        
        
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[headingLine]-[descriptionLine]-|" options:NSLayoutFormatAlignAllLeft metrics:0 views:views]];
        
        
        // align view from the left and right
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageView]-[descriptionLine]-|" options:0 metrics:nil views:views]];
      
 
    }
    else {
     
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}



@end
