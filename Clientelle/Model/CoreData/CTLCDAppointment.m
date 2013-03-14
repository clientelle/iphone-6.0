#import "CTLCDAppointment.h"
#import "NSDate+CTLDate.h"

@implementation CTLCDAppointment

+ (NSFetchedResultsController *)fetchedResultsController
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self entityInManagedObjectContext:context]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:CTLCDAppointmentAttributes.startDate ascending:NO]]];

    request.predicate = [NSPredicate predicateWithFormat:@"startDate >= %@ AND endDate =< %@", [NSDate date], [NSDate nextMonth]];
    
    NSFetchedResultsController *fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    NSError *fetchError = nil;
    BOOL working = [fetchController performFetch:&fetchError];
    if(!working) {
        NSLog(@"Failed to setup Fetched results controller: %@", fetchError);
    }
    return fetchController;
}

@end
