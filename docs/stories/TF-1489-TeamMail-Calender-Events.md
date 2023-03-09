# Summary

* [Related EPIC](#related-epic)
* [Definition](#definition)
* [Screenshots](#screenshots)
* [Misc](#misc)

## Related EPIC

* TODO: {link}

## Definition

- Given that I am a Tmail user, I have logged-in successfully and I can view calender events
- Event status:
             + Invitation: When I recieved an event invitation from other user, then I will recieve an Invitation email.
             + Updated invitation: When sender change event information, then I will recieve an Updated Invitation email.
             + Canceled event: When sender cancel event then I will recieve a Cancel event email.
             + Canceled event with note: When sender cancel event with note then I will recieve a Cancel event email with text note included in email details.

**UC1. As an user, I want to see the calender events via email on thread-view**
 _On thread-view, I can see email of calender events which having title include:_
- The icon indicator events in front of email title 
- The event status (Invitation/ Update invitation/ Cannceled event / Updated invitation)
- The event name
- The Date and Time with time zone of event
- The guest (reviever) email who be invited
- **Expected** event title email: **Event status: Event name @ DateAndTime (timezone) (guest email)**

**UC2.  As an user, I want to see the **Invitation** events on email details-view**
 _When I recieved an event invitation from other user then I can see Invitation email which having event information include:_
- The Calender icon indicator event date
- The event name
- The hyperlink to go to event (place to celebration event)
- The mini tips information of event (When event will be started!? Who are invited !? Where is the event place!?)
- The Yes/No button to let user decide to join or skip this event
- The description will be demonstrated in email description

**UC3.  As an user, I want to see the **Inivitation with note** calender events on email details-view**
_When I recieved an event invitation from other user then I can see Invitation email which having event information include:_
- The Calender icon indicator event date
- The event name
- The hyperlink to go to event (place to celebration event)
- The mini tips information of event (When event will be started!? Who are invited !? Where is the event place!?)
- The Yes/No button to let user decide to join or skip this event
- The blue message :_"You have been invited to the following event with this note: "Will happen every two weeks from now on."_
- The description will be demonstrated in email description

**UC4.  As an user, I want to see the Updated Invitation calender events on email details-view**
_When sender change event information, then I will recieve an Updated Invitation email which having event information include:_
- The Calender icon indicator event date
- The event name
- The hyperlink to go to event (place to celebration event)
- The mini tips information of event (When event will be started!? Who are invited !? Where is the event place!?)
- The Yes/No button to let user decide to join or skip this event
- The yeallow message :_"This event has been updated. Change:{DateAndTime}"_ System will display the changed information.
- The description will be demonstrated in email description

**UC5.  As an user, I want to see the **Canceled** events on email details-view**
 _When sender cancel event then I will recieve a Cancel event email which having event information include:_
- The Calender icon indicator event date
- The event name
- The mini tips information of event (This event is canceled)
- The description will be demonstrated in email description

**UC6.  As an user, I want to see the **Canceled with note** events on email details-view**
 _When sender cancel event with note then I will recieve a Cancel event with note email which having event information include:_
- The Calender icon indicator event date
- The event name
- The mini tips information of event (This event is canceled)
- The red message :_"This event has been canceled and  removed from your calender with a note: "Stop workshop"_
- The description will be demonstrated in email description


[Back to Summary](#summary)

## Screenshots:  https://www.figma.com/file/fAWU39IESCRj7J4h4JxoFt/Teammail%2FEmail-Calender-(Community)?node-id=0%3A1&t=mBPgDSWWEQVkibhF-1

None

[Back to Summary](#summary)

## Misc

None

[Back to Summary](#summary)
