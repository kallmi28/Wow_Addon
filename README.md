# TODO
* [ ] COME UP WITH A NAME
* [ ] fix issue, where it is not possible to anchor to the frame created after
    * possible solution is to move anchoring from constructor to different function, which will be called after all frames are created
* [ ] implement/change logic for showing secondary power bar
    * [x] find out if it is possible to change bar height in combat
        * it is possible to change height in combat, but not for secure frames
* [ ] create template for multi unit frames (party, raid, ...)
* [ ] define default data for all frames
    * [x] define default data for player frame
    * [x] define default data for target frame
    * [x] define default data for focus frame
    * [x] define default data for pet frame
    * [x] define default data for target of target frame
    * [ ] define default data for focus target frame
    * [ ] define default data for party frame
    * [ ] define default data for raid frame
    * [ ] define default data for boss frame
    * [ ] define default data for arena frame
    * [ ] define default data for tank frame
* [ ] finish settings panel
* [ ] connect widgets in settings panel with frames
* [x] implement fonts (+size)
* [ ] implement frame transparency (in combat/outside combat/in sanctuary/...)
* [ ] implement buff/debuff frame
* [ ] fix AFK/DND indication
* [ ] create separate file (class) for option window
* [ ] implement Blizz unit frame disabling/enabling 
* [ ] implement enabling frames
* [ ] implement test mode, where all enabled frames will be visible
* [ ] create own source file for option window
* [ ] implement absorb indication into frames