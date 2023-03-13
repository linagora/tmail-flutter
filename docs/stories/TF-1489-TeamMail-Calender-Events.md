# Summary

* [Related EPIC](#related-epic)
* [Definition](#definition)
* [Screenshots](#screenshots)
* [Misc](#misc)

## Related EPIC

* TODO: {link}

## Definition

- Given that I am a Tmail user, I have logged-in successfully and I can view calendar events.

**UC1. As an user, I want to see the calendar events invitation via email on thread-view**
 _On thread-view, I can see email of calendar events which having title include:_
- The icon indicator events in front of email title 
- The icon indicator .ics file which having in events email
- The event name on subject
- The event short description
- The host name (sender) email who be created an event
- The event status (New / Updated / Canceled)
- **Expected** event email: **[Events icon] EventStatus from HostName (email description) [Attachment icon]**

       **_New event sample:_** **[Events icon] New event from Benoît TELLIER** _Benoît TELLIER has invited you to a meeting EventName Time: Friday 10 March 2023 11:00 - 12:00..._  [Attachment icon]
       **_Updated event sample:_** **[Events icon] EventName from Benoît TELLIER updated** _Benoît TELLIER has updated a meeting EventName TimeChanged: Friday 10 March 2023 11:00 - 12:00..._  [Attachment icon]
       **_Canceled event sample:_** **[Events icon] EventName from Benoît TELLIER canceled** _Benoît TELLIER has canceled a meeting EventName Time: Friday 10 March 2023 11:00 - 12:00..._  [Attachment icon]

**UC2. As an user, I want to see the calendar events invitation via email on details-view**
 _On details-view, I can see description of calendar events which having description include:_
- The Calendar icon indicator event date
- The event name on subject:

      **_New event sample:_** **New event from Benoît TELLIER: TFK
      **_Updated event sample:_** **Event TFK from Benoît TELLIER updated
      **_Canceled event sample:_** **Event TFK from Benoît TELLIER canceled

- The notification with color to describe each event status:

       **_New event sample: GREEN COLOR_** **Benoît TELLIER has invited you to a meeting
       **_Updated event sample: YEALLOW COLOR_** **Benoît TELLIER has updated a meeting
       **_Canceled event sample: RED COLOR_** **Benoît TELLIER has canceled a meeting

- The mini tips information of event (When event will be started!? Who are invited !? Where is the event place!?)
- The description will be demonstrated in email description
- **Yes/Maybe/No** button to select my decision _(Only display in case event status = New/Update, not display in case event status = Canceled)_

**UC3. As an user, I want to see the decision of receiver via email on thread-view**
 _On thread-view, I can see email from each decision of receiver which having title include:_
- The icon indicator events in front of email title 
- The icon indicator .ics file which having in events email
- The event name on subject
- The event short description
- The ReceiverName email who be invited to this event
- The decision type (Accepted/Tentatively/Declined) which displayed following action (Yes/Maybe/No)
- **Expected** decision event email: **[Events icon] DecisionType: EventName (ReceiverName) (email description) [Attachment icon]**

        **_Accepted event sample:_** **[Events icon] Accepted: EventName (Benoît TELLIER)** _Benoît TELLIER has accepted this invitation EventName Time: Friday 10 March 2023 11:00 - 12:00..._  [Attachment icon]
        **_Tentatively accepted event sample:_** **[Events icon] Tentatively accepted: EventName (Benoît TELLIER)** _Benoît TELLIER has replied "Maybe" to this invitation EventName TimeChanged: Friday 10 March 2023 11:00 - 12:00..._  [Attachment icon]
        **_Declined event sample:_** **[Events icon] Declined: EventName (Benoît TELLIER)** _Benoît TELLIER has declined this invitation EventName Time: Friday 10 March 2023 11:00 - 12:00..._  [Attachment icon]

**UC4.  As an user, I want to see the decision of receiver on email details-view**
 _When receiver click to (Yes/Maybe/No) button to make a decision for events invitation then I can see (Accepted/Tentatively/Declined) email which having description include:_
- The Calendar icon indicator event date
- The event name on subject:

      **_Accepted event sample:_** **Accepted: EventName (Benoît TELLIER)
      **_Tentatively accepted event sample:_** **Tentatively accepted: EventName (Benoît TELLIER)
      **_Declined event sample:_** **Declined: EventName (Benoît TELLIER)

- The notification with color to describe each event status:

       **_Accepted event sample: GREEN COLOR_** **Benoît TELLIER has accepted this invitation
       **_Tentatively accepted event sample: YEALLOW COLOR_** **Benoît TELLIER has replied "Maybe" to this invitation
       **_Declined event sample: RED COLOR_** **Benoît TELLIER has declined this invitation

- The mini tips information of event (When event will be started!? Who are invited !? Where is the event place!?)
- The description will be demonstrated in email description


[Back to Summary](#summary)

## Screenshots: https://www.figma.com/file/fAWU39IESCRj7J4h4JxoFt/Teammail%2FEmail-Calender-(Community)?node-id=0%3A1&t=QQRSAgHhAhsmiPNx-1
None

[Back to Summary](#summary)

## Misc

None

[Back to Summary](#summary)
