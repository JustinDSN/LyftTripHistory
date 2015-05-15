# LyftTripHistory
This project automatically tracks trips.  When the device is moving faster than 10 mph, a trip is created, when the device stops moving for one minute, the trip is ended.

## Design Patterns
This project showcases numerous software engineering design patterns.

- [State Machine](LyftTripHistory/LTHLocationManager.m#L170-L315) and [aggregated enumeration](LyftTripHistory/LTHLocationManager.h#L12-L18) for managing the interaction between location services permissions and the trip logging switch state.
- [Key Value Coding (KVC)](/LyftTripHistory/LTHTrip.m#L182-L206) to allow trips to be persisted to a file stored on the phone.
- [Key Value Observing (KVO)](/LyftTripHistory/LTHTripStore.m#L69-L70) to update table view cells when a model's property changes.
- [Dependency Injection](/LyftTripHistory/AppDelegate.m#L42-L43) for easier testability.
- Single responsibility pattern and [delegation](LyftTripHistory/LTHHistoryTableViewController.m#L86-L150) for better decoupling and separation of concerns.
- Lazily instantiated static variables for performance ([NSDateFormatter](LyftTripHistory/LTHTrip.m#L42-L47), and [CLGeocoder](LyftTripHistory/LTHTrip.m#L146-L148))
- [Dynamic Sizing Table View Cells](LyftTripHistory/LTHHistoryTableViewController.m#L29-L30)
- [Unit Tests](LyftTripHistoryTests/LTHTripTests.m) to test logic in isolation.
