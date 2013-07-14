//
//  AccountColorViewController.m
//  WizardWar
//
//  Created by Sean Hess on 7/14/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "AccountColorViewController.h"
#import "UIColor+Hex.h"
#import "NSArray+Functional.h"

#define COLOR_CELL_IDENTIFIER @"ColorCell"

@interface AccountColorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSArray * colorOptions;

@property (strong, nonatomic) UICollectionView * collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout * flowLayout;
@end

@implementation AccountColorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.itemSize = CGSizeMake(32, 32);
    self.flowLayout.minimumInteritemSpacing = 1.0;
    self.flowLayout.minimumLineSpacing = 1.0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:COLOR_CELL_IDENTIFIER];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // Optional Colors!
    NSArray * hexColors = @[@(0xFFC0CB),@(0xFFB6C1),@(0xFF69B4),@(0xFF1493),@(0xDB7093),@(0xC71585),@(0xFFA07A),@(0xFA8072),@(0xE9967A),@(0xF08080),@(0xCD5C5C),@(0xDC143C),@(0xB22222),@(0x8B0000),@(0xFF0000),@(0xFF4500),@(0xFF6347),@(0xFF7F50),@(0xFF8C00),@(0xFFA500),@(0xFFD700),@(0xFFFF00),@(0xFFFFE0),@(0xFFFACD),@(0xFAFAD2),@(0xFFEFD5),@(0xFFE4B5),@(0xFFDAB9),@(0xEEE8AA),@(0xF0E68C),@(0xBDB76B),@(0xFFF8DC),@(0xFFEBCD),@(0xFFE4C4),@(0xFFDEAD),@(0xF5DEB3),@(0xDEB887),@(0xD2B48C),@(0xBC8F8F),@(0xF4A460),@(0xDAA520),@(0xB8860B),@(0xCD853F),@(0xD2691E),@(0x8B4513),@(0xA0522D),@(0xA52A2A),@(0x800000),@(0x556B2F),@(0x808000),@(0x6B8E23),@(0x9ACD32),@(0x32CD32),@(0x00FF00),@(0x7CFC00),@(0x7FFF00),@(0xADFF2F),@(0x00FF7F),@(0x00FA9A),@(0x90EE90),@(0x98FB98),@(0x8FBC8F),@(0x3CB371),@(0x2E8B57),@(0x228B22),@(0x008000),@(0x006400),@(0x66CDAA),@(0x00FFFF),@(0x00FFFF),@(0xE0FFFF),@(0xAFEEEE),@(0x7FFFD4),@(0x40E0D0),@(0x48D1CC),@(0x00CED1),@(0x20B2AA),@(0x5F9EA0),@(0x008B8B),@(0x008080),@(0xB0C4DE),@(0xB0E0E6),@(0xADD8E6),@(0x87CEEB),@(0x87CEFA),@(0x00BFFF),@(0x1E90FF),@(0x6495ED),@(0x4682B4),@(0x4169E1),@(0x0000FF),@(0x0000CD),@(0x00008B),@(0x000080),@(0x191970),@(0xE6E6FA),@(0xD8BFD8),@(0xDDA0DD),@(0xEE82EE),@(0xDA70D6),@(0xFF00FF),@(0xFF00FF),@(0xBA55D3),@(0x9370DB),@(0x8A2BE2),@(0x9400D3),@(0x9932CC),@(0x8B008B),@(0x800080),@(0x4B0082),@(0x483D8B),@(0x6A5ACD),@(0xFFFFFF),@(0xFFFAFA),@(0xF0FFF0),@(0xF5FFFA),@(0xF0FFFF),@(0xF0F8FF),@(0xF8F8FF),@(0xF5F5F5),@(0xFFF5EE),@(0xF5F5DC),@(0xFDF5E6),@(0xFFFAF0),@(0xFFFFF0),@(0xFAEBD7),@(0xFAF0E6),@(0xFFF0F5),@(0xFFE4E1),@(0xDCDCDC),@(0xD3D3D3),@(0xD3D3D3),@(0xC0C0C0),@(0xA9A9A9),@(0xA9A9A9),@(0x808080),@(0x808080),@(0x696969),@(0x696969),@(0x778899),@(0x778899),@(0x708090),@(0x708090),@(0x2F4F4F),@(0x2F4F4F),@(0x000000)];
    
    self.colorOptions = [hexColors map:^(NSNumber * rgb) {
        return [UIColor colorFromRGB:rgb.integerValue];
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView reloadData];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLOR_CELL_IDENTIFIER forIndexPath:indexPath];
    cell.backgroundColor = self.colorOptions[indexPath.row];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorOptions.count;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(30, 30);
//}

// This is the SECTION inset. not the cell inset. OHHHH
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(8,0,0,0);
//}

//- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 0;
//}

//- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 0;
//}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIColor * color = self.colorOptions[indexPath.row];
    [self.delegate didSelectColor:color];
}


@end
