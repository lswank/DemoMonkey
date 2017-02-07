# What is it?
DemoMonkey is an old Apple sample code shared and used during WWDC. It allows a presenter to prepare a series of snippets to be pushed in the pasteboard.

Code has been provided as samples code by Apple for 10.6 then the Big Nerd Ranch maintained it until 2015.

In 2017, @ygini forked it from @bignerdranch and did the small updates needed to build it on 10.12 and provide a gatekeeper compatible release via Github system (so, compatible with autopkg for example).

# How to use it?

Run the app, create a new document if needed, then in `File` select `Edit Steps`. From here you can add and edit steps as wanted.

Be careful for a known bug (will be fixed ASAP): when you edit a step content, be sure to select another step before saving. Otherwise updated content won't be saved.

Then, during presentation, you just have to open your document and use the arrows on your keyboard to select your steps. Each time the selection changes in the table view, the related content is loaded into your pasteboard.

This mean you simply have to use cmd tab to move from your demo content to DemoMonkey, select your step, then move back with cmd tab again. If you're confident with your steps and don't need to see them, you can use the application preferences to set the alpha value of the main window and make it transparent to keep everything just magic. :-)