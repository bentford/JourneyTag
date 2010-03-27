//
//  TestOneTableViewController.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TestOneTableViewController.h"


@implementation TestOneTableViewController
@synthesize tagKey, accountKey, photoKey;

- (void)awakeFromNib
{
    accountService = [[JTAccountService alloc] init];
    markService = [[JTMarkService alloc] init];
    photoService = [[JTPhotoService alloc] init];
    tagService = [[JTTagService alloc] init];
    depotService = [[JTDepotService alloc] init];    
    inventoryService = [[JTInventoryService alloc] init];
    scoreService = [[JTScoreService alloc] init];
    shouldTestLogout = YES;
    titles = [[NSMutableArray alloc] initWithCapacity:1];
    [titles addObject:@"start"];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [titles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [titles objectAtIndex:indexPath.row];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if( indexPath.row == 0  ) {
        shouldTestLogout = YES;
        [self runTestStructure];
    }
}


#pragma mark test structure

- (void) runTestStructure
{
    if( shouldTestLogout  ) //confusing, but don't clear titles while we are testing logout
    {
        [titles release];
        titles = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [self updateTable:@"login attempt"];
    [accountService login:@"1234" username:@"testharnessaccount" password:@"hendrix" delegate:self didFinish:@selector(run2:) didFail:@selector(didFail:)];
    
}

- (void) run2:(NSDictionary*)dict {
    self.accountKey = [dict valueForKey:@"accountKey"];
    if( [accountKey caseInsensitiveCompare:@"NotFound"] == NSOrderedSame ) {
        [self updateTable:@"account not found"];
        
        [self updateTable:@"creating account"];
        [accountService createAccount:@"1234" username:@"testharnessaccount" password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:@selector(runTestStructure:) didFail:@selector(didFail:)];    
        return;
    }

    [self run2_0:dict];
}

- (void) run2_0:(NSDictionary*)dict {
    
    [self updateTable:@"login success"];
    self.accountKey = [dict valueForKey:@"accountKey"];

    [self updateTable:@"try creating dup account"];
    [accountService createAccount:@"1234" username:@"testharnessaccount" password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:@selector(run2_1:) didFail:@selector(didFail:)];    
}

- (void) run2_1:(NSDictionary*)dict {
    NSString *value = [dict valueForKey:@"accountKey"];
    
    if( [value caseInsensitiveCompare:@"NotUnique"] == NSOrderedSame )
        [self updateTable:@"was dup account"];
    else {
        [self updateTable:@"not dup account (problem!!)"];
        return; //stop testing
    }
    
    if( shouldTestLogout )
    {
        [self updateTable:@"logout test"];
        shouldTestLogout = NO;
        [accountService logout:self didFinish:@selector(runTestStructure) didFail:@selector(didFail:)];
    } else {
        shouldTestLogout = YES;
        [self run2_2:nil];
    }
}

- (void)run2_2:(NSDictionary*)dict
{    
    [accountService getAccountInfo:self didFinish:@selector(run2_3:) didFail:@selector(didFail:)];
}

- (void) run2_3:(NSDictionary*)dict
{
    [self updateTable:@"account info"];
    [tagService create: @"To portland and back" destLat:27.9999 destLon:-128.0005 destinationAccuracy:5000 delegate:self didFinish:@selector(run3:) didFail:@selector(didFail:)];      
}

- (void) run3:(NSDictionary*)dict
{
    self.tagKey = [dict valueForKey:@"tagKey"];
    
    [self updateTable:@"created tag"];

    [tagService updateTagWithKey:self.tagKey name:@"To Portland and back" destLat:32.1234 destLon:-132.123 destinationAccuracy:100 delegate:self didFinish:@selector(run4:) didFail:@selector(didFail:)];
//    [tagService updateTagWithKey:self.tagKey name:@"To Portland and Back" delegate:self didFinish:@selector(run4:) didFail:@selector(didFail:)];
}
- (void) run4:(NSDictionary*)dict
{
    [self updateTable:@"update tag"];
    
    [tagService getAllForYourAccount:self didFinish:@selector(run5:) didFail:@selector(didFail)];
}
- (void) run5:(NSDictionary*)dict
{
    NSArray *allTags = [dict objectForKey:@"tags"];
    NSString *message1 = [[NSString alloc] initWithFormat:@"Found %d tags",[allTags count]];
    [self updateTable:message1];
    [message1 release];
    
    UIImage *image = [UIImage imageNamed:@"TestPicture.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [photoService createPhoto:imageData delegate:self didFinish:@selector(run6:) didFail:@selector(didFail)];
}
-(void) run6:(NSDictionary*)dict
{
    self.photoKey = [dict valueForKey:@"photoKey"];
    [self updateTable:@"created photo"];
    
[markService create:tagKey photoKey:photoKey lat:28 lon:-128 delegate:self didFinish:@selector(run7:) didFail:@selector(didFail)];
}

- (void) run7:(NSDictionary*)dict
{
    [self updateTable:@"Created mark"];
    
    [markService getAllForTag:tagKey delegate:self didFinish:@selector(run8:) didFail:@selector(didFail)];
}

- (void) run8:(NSDictionary*)dict
{
    NSArray *allMarks = [dict objectForKey:@"marks"];
    NSString *message2 = [[NSString alloc] initWithFormat:@"mark count: %d",[allMarks count]];
    [self updateTable:message2];
    [message2 release];
    
    [self updateTable:@"get all depots"];
    [depotService getAllByStatus:YES delegate:self didFinish:@selector(run9:) didFail:@selector(didFail)];
}

- (void) run9:(NSDictionary*)dict
{
    NSArray *depots = [dict objectForKey:@"depots"];
    
    NSString *message3 = [[NSString alloc] initWithFormat:@"depot count: %d",[depots count]];
    [self updateTable:message3];
    [message3 release];
    
    [depotService create:self didFinish:@selector(run10:) didFail:@selector(didFail:)];      
}

- (void) run10:(NSDictionary*)dict
{
    NSString *depot1 = [dict valueForKey:@"depotKey"];
    UIImage *image = [UIImage imageNamed:@"TestPicture.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [depotService drop:depot1 imageData:imageData lat:28 lon:-128 delegate:self didFinish:@selector(run11:) didFail:@selector(didFail:)];  
}

-(void) run11:(NSDictionary*)dict
{
    depotKey = [[dict valueForKey:@"depotKey"] retain];
    [self updateTable:@"dropped depot1"];
    [depotService pickup:depotKey delegate:self didFinish:@selector(run11b:) didFail:@selector(didFail:)];          
}

- (void) run11b:(NSDictionary*)dict
{
    
    UIImage *image = [UIImage imageNamed:@"TestPicture.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [depotService drop:depotKey imageData:imageData lat:28 lon:-128 delegate:self didFinish:@selector(run11b1:) didFail:@selector(didFail:)];      
}

- (void) run11b1:(NSDictionary*)dict
{
    [self updateTable:@"dropped depot again (for further testing)"];
    [tagService pickup:tagKey delegate:self didFinish:@selector(run11c:) didFail:@selector(didFail:)];
}

-(void) run11c:(NSDictionary*)dict
{
    [self updateTable:@"re-picked up tag"];
    [tagService dropAtDepot:tagKey depotKey:depotKey delegate:self didFinish:@selector(run11d:) didFail:@selector(didFail:)];
}

-(void) run11d:(NSDictionary*)dict
{
    UIImage *image = [UIImage imageNamed:@"TestPicture.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    [self updateTable:@"DropAndPickup"];
    [tagService dropAndPickup:tagKey imageData:imageData lat:28 lon:-128 delegate:self didFinish:@selector(run12:) didFail:@selector(didFail:)];
}

-(void) run12:(NSDictionary*)dict
{
    [self updateTable:@"dropped tag at depot"];
    [inventoryService create:self.tagKey delegate:self didFinish:@selector(run13:) didFail:@selector(didFail:)];
}

- (void) run13:(NSDictionary*)dict
{
    [self updateTable:@"added to inventory"];
    [inventoryService get:self.accountKey delegate:self didFinish:@selector(run14:) didFail:@selector(didFail:)];
}

- (void) run14:(NSDictionary*)dict
{
    NSArray *inventories = [dict objectForKey:@"inventories"];
    NSString *message = [[NSString alloc] initWithFormat:@"get %d from inventory",[inventories count]];
    [self updateTable:message];
    [message release];
    
    [[inventories objectAtIndex:0] valueForKey:@"key"];
    [inventoryService delete:self.tagKey delegate:self didFinish:@selector(run15:) didFail:@selector(didFail:)];
}

- (void) run15:(NSDictionary*)dict
{
    [self updateTable:@"deleted inventory"];
    [tagService pickup:self.tagKey delegate:self didFinish:@selector(run16:) didFail:@selector(didFail:)];
}

- (void) run16:(NSDictionary*)dict
{
    [self updateTable:@"picked up tag"];
    UIImage *image = [UIImage imageNamed:@"TestPicture.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
    [tagService drop:self.tagKey imageData:imageData lat:28 lon:-128 delegate:self didFinish:@selector(run17:) didFail:@selector(didFail:)];
}

- (void) run17:(NSDictionary*)dict
{
    [self updateTable:@"dropped tag"];
    [tagService getForCoordinate:28 viewLon:-128 physicalLat:28 physicalLon:-128 delegate:self didFinish:@selector(run18:) didFail:@selector(didFail:)];
}

- (void) run18:(NSDictionary*)dict
{
    NSArray *tags = [dict objectForKey:@"tags"];
    NSString *message = [[NSString alloc] initWithFormat:@"tags closeby: %d",[tags count]];
    [self updateTable:message];
    [message release];
    
    [tagService get:self.tagKey delegate:self didFinish:@selector(run19:) didFail:@selector(didFail:)];
}

- (void) run19:(NSDictionary*)dict
{
    [self updateTable:@"got tag's info"];
    
    [photoService flagPhoto:photoKey flag:YES delegate:self didFinish:@selector(run20:) didFail:@selector(didFail:)];
}

- (void) run20:(NSDictionary*)dict
{
    [self updateTable:@"Did Flag Photo"];
    [photoService likePhoto:photoKey like:YES delegate:self didFinish:@selector(run20_1:) didFail:@selector(didFail:)];
}

- (void)run20_1:(NSDictionary*)dict
{
    [photoService likePhoto:photoKey like:NO delegate:self didFinish:@selector(run21:) didFail:@selector(didFail:)];
}

- (void) run21:(NSDictionary*)dict
{
    [self updateTable:@"Liked photo"];
    [depotService getAllAsTargetForTag:tagKey delegate:self didFinish:@selector(run22:) didFail:@selector(didFail:)];
}

- (void) run22:(NSDictionary*)dict
{
    [self updateTable:@"depots-target-tag"];
    [scoreService getPhotoScores:self didFinish:@selector(run23:) didFail:@selector(didFail:)];
}

- (void)run23:(NSDictionary*)dict
{
    [self updateTable:@"photo score"];
    [scoreService getCarryScores:self didFinish:@selector(run24:) didFail:@selector(didFail:)];
}

- (void)run24:(NSDictionary*)dict
{
    [self updateTable:@"carry score"];
    [scoreService getArriveScores:self didFinish:@selector(run25:) didFail:@selector(didFail:)];
}

- (void) run25:(NSDictionary*)dict
{
    [self updateTable:@"arrive score"];
    [tagService problem:tagKey problemCode:1 delegate:self didFinish:@selector(run26:) didFail:@selector(didFail:)];

}

- (void)run26:(NSDictionary*)dict
{
    [self updateTable:@"reported problem"];
    [tagService delete:tagKey delegate:self didFinish:@selector(run27:) didFail:@selector(didFail:)];    
}

- (void)run27:(NSDictionary*)dict
{
    if( [(NSString*)[dict objectForKey:@"tagKey"] compare:tagKey] == NSOrderedSame )
        [self updateTable:@"deleted tag"];
    else
        [self updateTable:@"error"];
}

- (void)didFail:(NSDictionary *)info {
    NSLog(@"I FAILED YOU MASTER - %@", [info objectForKey:@"error"]);
    NSLog(@"Server Output: %@", [info objectForKey:@"responseString"]);
}

- (void) updateTable:(NSString*)message
{
    [titles addObject:message];
    [self.tableView reloadData];
}

- (void)dealloc {
    [super dealloc];
}


@end

