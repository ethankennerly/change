package com.finegamedesign.change
{
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.getTimer;
    import flash.utils.setTimeout;

    import org.flixel.system.input.KeyMouse;
    // import org.flixel.plugin.photonstorm.API.FlxKongregate;
    // import com.newgrounds.API;

    public dynamic class Main extends Sprite
    {
        internal var keyMouse:KeyMouse;
        private var model:Model;
        private var view:View;
        private var sounds:Sounds;

        public function Main()
        {
            if (stage) {
                init(null);
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
            }
        }
       
        public function init(event:Event=null):void
        {
            sounds = new Sounds();
            // scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            keyMouse = new KeyMouse();
            keyMouse.listen(stage);
            view = new View(this);
            view.screen.mouseChildren = false;
            view.screen.mouseEnabled = false;
            view.screen.rounds.addEventListener(
                MouseEvent.CLICK,
                answer, false, 0, true);
            model = new Model(view.rounds[0],  view.rounds.length);
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            view.screen.addFrameScript(2, trial);
            view.screen.addFrameScript(view.screen.totalFrames - 2, trialLoop);
            view.backgroundClip.addFrameScript(view.backgroundClip.totalFrames - 2, restart);
            // API.connect(root, "", "");
        }

        private function restart():void
        {
            view.restart();
            init();
        }

        private function trialEnable():void
        {
            trace("Main.trialEnable");
            model.enabled = true;
            view.backgroundClip.stop();
            view.screen.gotoAndPlay("begin");
            view.screen.mouseChildren = true;
            view.screen.mouseEnabled = true;
        }

        private function trialBegin():void
        {
            view.screen.gotoAndPlay("begin");
        }

        private function trialLoop():void
        {
            if (model.enabled) {
                view.screen.gotoAndStop("begin");
                setTimeout(trialBegin, model.interStimulusInterval);
            }
            else {
                view.hideScreen();
            }
        }

        public function trial():void
        {
            clear();
            model.populate();
            view.populate(model);
            if (model.tutor) {
            }
            else if (model.review) {
                view.review();
            }
        }

        /**
         * Cheats to quickly test:
         *      "ENTER" complete trial.
         *      "DELETE", "ESC", "X" this is the last trial. DELETE key different on Mac than Windows.
         */
        private function update(event:Event):void
        {
            var now:int = getTimer();
            keyMouse.update();
            // After stage is setup, connect to Kongregate.
            // http://flixel.org/forums/index.php?topic=293.0
            // http://www.photonstorm.com/tags/kongregate
            /* 
            if (! FlxKongregate.hasLoaded && stage != null) {
                FlxKongregate.stage = stage;
                FlxKongregate.init(FlxKongregate.connect);
            }
             */
            if (keyMouse.justPressed("DELETE")
             || keyMouse.justPressed("ESCAPE")
             || keyMouse.justPressed("X")) {
                model.truncate();
            }
            if (keyMouse.justPressed("ENTER")) {
                if (model.enabled) {
                    trialEnd(true);
                }
            }
            if (keyMouse.justPressed("LEFT")) {
                model.trial--;
            }
            if (keyMouse.justPressed("RIGHT")) {
                model.trial++;
            }
            if (keyMouse.justPressed("MOUSE")) {
                model.listen();
            }
            if (!model.enabled && !model.inTrial 
            && "trialEnable" == view.backgroundClip.currentLabel) {
                trialEnable();
            }
        }

        /**
         * Save level at highest of previous level or current.
         */
        private function trialEnd(correct:Boolean):void
        {
            model.trialEnd(correct);
            if (correct) {
                view.trialEnd();
                if (model.reviewing) {
                }
                if (model.enabled) {
                    view.win();
                }
                else {
                    view.end();
                }
            }
            // FlxKongregate.api.stats.submit("Score", Model.score);
            // API.postScore("Score", Model.score);
        }

        public function clear():void
        {
            if (null != view) {
                view.clear();
            }
        }

        // Game-specific:

        private function answer(e:MouseEvent):void
        {
            if (model.listening) {
                var x:Number = e.currentTarget.stage.mouseX;
                var y:Number = e.currentTarget.stage.mouseY;
                var positionIndex:int = view.indexOf(x, y);
                if (positionIndex <= -1) {
                }
                else {
                    var correct:Boolean = model.answer(positionIndex);
                    if (correct) {
                        sounds.correct();
                        view.feedback(positionIndex, true);
                        trialEnd(true);
                    }
                    else {
                        view.feedback(positionIndex, false);
                        sounds.wrong();
                        trialEnd(false);
                    }
                }
            }
            if (model.enabled && model.complete) {
                view.screen.play();
            }
        }
    }
}
