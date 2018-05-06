//
//  ViewController.m
//  Ramping_ObjectiveC_Application
//
//  Created by Steven Hurtado on 5/3/18.
//  Copyright © 2018 Steven Hurtado. All rights reserved.
//

#import "ViewController.h"

typedef enum {
    Textured,
    Solid
} BrushStyle;

typedef enum {
    Light,
    Standard,
    Heavy
} BrushWeight;

@interface ViewController ()
@end
@interface CanvasView : UIImageView

@end

@implementation CanvasView
CGFloat defaultLineWidth = 6.0;
CGFloat forceSensitivity = 4.0;
UIColor * defaultStyle = nil;

BrushWeight canvasWeight = Standard;
BrushStyle canvasStyle = Solid;

-(void)setDefaults:(BrushWeight) weight withStyle: (BrushStyle) style {
    canvasWeight = weight;
    canvasStyle = style;
    
    [self adjustDefaults];
}

-(void)adjustDefaults {
    switch(canvasWeight) {
        case Light:
            defaultLineWidth = 1.0;
            forceSensitivity = 1.0;
            break;
        case Standard:
            defaultLineWidth = 6.0;
            forceSensitivity = 4.0;
            break;
        case Heavy:
            defaultLineWidth = 12.0;
            forceSensitivity = 8.0;
            break;
        default:
            break;
    }
    
    switch(canvasStyle)
    {
        case Solid:
            defaultStyle = [UIColor darkTextColor];
            break;
        case Textured:
            defaultStyle = [UIColor colorWithPatternImage: [UIImage imageNamed: @"PencilTexture"]];
            break;
        default:
            break;
    }
}

-(void) Stroke {
    [defaultStyle setStroke];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
}
-(void)touchesEstimatedPropertiesUpdated:(NSSet<UITouch *> *)touches {
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [[event allTouches] anyObject];
    
    UIGraphicsBeginImageContextWithOptions([self bounds].size, false, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[self image] drawInRect: [self bounds]];
    
    NSSet<UITouch *> * touchSet = [[NSSet<UITouch *> alloc] init];
    NSArray<UITouch *> * coalesced = [event coalescedTouchesForTouch: touch];
    if(coalesced == nil)
    {
        touchSet = [NSSet<UITouch *> setWithObject:touch];
    }
    else
    {
        touchSet = [NSSet<UITouch *> setWithArray:coalesced];
    }
    
    [touchSet enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        [self drawStroke: context withTouch:obj];
    }];
    
    //update image
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)drawStroke:(CGContextRef)context withTouch: (UITouch *)touch {
    CGPoint previous = [touch previousLocationInView: self];
    CGPoint location = [touch locationInView:self];
    CGFloat lineWidth = [self lineWidthForDrawing: context withTouch:touch];
    
    [self Stroke];
    
    // Configure lineC
    CGContextSetLineWidth(context, lineWidth);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    
    // Set up the points
    CGContextMoveToPoint(context, previous.x, previous.y);
    CGContextAddLineToPoint(context, location.x, location.y);
    // Draw the stroke
    CGContextStrokePath(context);
}

-(CGFloat) lineWidthForDrawing: (CGContextRef) context withTouch: (UITouch *) touch {
    CGFloat width = defaultLineWidth;
    if(touch.force > 0)
    {
        width = touch.force * forceSensitivity;
    }
    return width;
}

-(void) ClearCanvas: (BOOL) animated {
    if(animated) {
        [UIView animateWithDuration:0.48 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished){
            self.image = nil;
            [UIView animateWithDuration:0.48 animations:^{
                self.alpha = 1;
            }];
        }];
    }
    else {
        self.image = nil;
    }
}

@end

@implementation ViewController
CanvasView * Canvas;
UILabel * myLabel;
UISegmentedControl * ControlStyle;
UISegmentedControl * ControlWeight;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpViews];
    [self setUpComponents];
}

-(void)setUpViews {
    [self setUpLabel];
    [self setUpCanvas];
    [self setUpSegments];
}

- (void)setUpLabel {
    myLabel = [[UILabel alloc] init];
    myLabel.text = @"Sketch It!";
    myLabel.backgroundColor = self.view.tintColor;
    myLabel.textColor = UIColor.whiteColor;
    myLabel.textAlignment = NSTextAlignmentCenter;
    
    //shadow set up
    myLabel.layer.masksToBounds = NO;
    myLabel.layer.shadowOffset = CGSizeMake(0.0f, 2.48f);
    myLabel.layer.shadowRadius = 1.24f;
    myLabel.layer.shadowOpacity = 0.48f;
    myLabel.layer.shadowColor = UIColor.darkTextColor.CGColor;
    
    [[self view] addSubview: myLabel];
}

-(void)setUpCanvas {
    Canvas = [[CanvasView alloc] init];
    Canvas.layer.borderWidth = 1.0;
    Canvas.layer.borderColor = self.view.tintColor.CGColor;
    Canvas.backgroundColor = UIColor.whiteColor;
    
    //shadow set up
    Canvas.layer.masksToBounds = NO;
    Canvas.layer.shadowOffset = CGSizeMake(0.0f, 2.48f);
    Canvas.layer.shadowRadius = 1.24f;
    Canvas.layer.shadowOpacity = 0.48f;
    Canvas.layer.shadowColor = UIColor.darkTextColor.CGColor;

    [[self view] addSubview: Canvas];
}

-(void)setUpSegments {
    NSArray * brushStyles = @[@("Solid"),@("Textured")];
    ControlStyle = [[UISegmentedControl alloc] initWithItems: brushStyles];
    [ControlStyle addTarget:self action:@selector(StyleChanged:) forControlEvents:UIControlEventValueChanged];
    ControlStyle.selectedSegmentIndex = 0;
    
    NSArray * brushWeights = @[@("Light"),@("Standard"),@("Heavy")];
    ControlWeight = [[UISegmentedControl alloc] initWithItems: brushWeights];
    [ControlWeight addTarget:self action:@selector(WeightChanged:) forControlEvents:UIControlEventValueChanged];
    ControlWeight.selectedSegmentIndex = 1;
    
    [[self view] addSubview:ControlStyle];
    [[self view] addSubview:ControlWeight];
}

-(void)StyleChanged:(UISegmentedControl *) segment {
    switch(segment.selectedSegmentIndex) {
        case 0:
            [Canvas setDefaults:canvasWeight withStyle:Solid];
            break;
        case 1:
            [Canvas setDefaults:canvasWeight withStyle:Textured];
            break;
        default:
            break;
    }
}

-(void)WeightChanged:(UISegmentedControl *) segment {
    switch(segment.selectedSegmentIndex) {
        case 0:
            [Canvas setDefaults:Light withStyle:canvasStyle];
            break;
        case 1:
            [Canvas setDefaults:Standard withStyle:canvasStyle];
            break;
        case 2:
            [Canvas setDefaults:Heavy withStyle:canvasStyle];
            break;
        default:
            break;
    }
}

-(void)setUpComponents {
    [self setUpTouch];
    [self setUpClearing];
    [self setUpConstraints];
}

-(void)setUpTouch {
    [Canvas setUserInteractionEnabled: YES];
}

-(void)setUpClearing {
    [Canvas ClearCanvas: false];
}
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [Canvas ClearCanvas: true];
}

-(void)setUpConstraints {
    //Constraints for Label
    myLabel.translatesAutoresizingMaskIntoConstraints = false;
    [[myLabel.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor constant:-184.f] setActive: YES];
    [[myLabel.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor constant:48.f]setActive: YES];
    [[myLabel.bottomAnchor constraintEqualToAnchor:Canvas.topAnchor constant:-16.f] setActive: YES];
    [[myLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:48.f] setActive: YES];
    
    //heightConstraint on Label
    [[myLabel.heightAnchor constraintGreaterThanOrEqualToConstant: 48] setActive: YES];
    
    //Constraints for Canvas
    Canvas.translatesAutoresizingMaskIntoConstraints = false;
    [[Canvas.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor constant:-184.f] setActive: YES];
    [[Canvas.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor constant:48.f]setActive: YES];
    [[Canvas.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-48.f] setActive: YES];
    [[Canvas.topAnchor constraintEqualToAnchor:myLabel.bottomAnchor constant:-16.f] setActive: YES];
    
    //constraints for controls
    
    ControlStyle.translatesAutoresizingMaskIntoConstraints = false;
    [[ControlStyle.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor constant:8.f] setActive: YES];
    [[ControlStyle.leadingAnchor constraintEqualToAnchor:Canvas.trailingAnchor constant:8.f]setActive: YES];
    [[ControlStyle.topAnchor constraintEqualToAnchor:myLabel.bottomAnchor constant:16.f] setActive: YES];
    
    ControlWeight.translatesAutoresizingMaskIntoConstraints = false;
    [[ControlWeight.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor constant:8.f] setActive: YES];
    [[ControlWeight.leadingAnchor constraintEqualToAnchor:Canvas.trailingAnchor constant:8.f]setActive: YES];
    [[ControlWeight.topAnchor constraintEqualToAnchor:ControlStyle.bottomAnchor constant:16.f] setActive: YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
