package com.finegamedesign.change
{
    import flash.geom.Rectangle;

    public class Model
    {
        internal function get interStimulusInterval():int
        {
            var thickness:Number = thicknesses[targets[0]];
            var base:Number = 400;
            var max:Number = 1000;
            var thick:Number = thickness / base;
            return thick * Math.max(0,
                max * Math.min((referee.percent - 80) * 0.05,
                    2 * trial / trialMax));
        }

        internal var target:int;
        internal var targets:Array;
        internal var positions:Array;
        internal var enabled:Boolean = false;
        internal var inTrial:Boolean = false;
        internal var listening:Boolean = false;
        internal var referee:Referee = new Referee();
        internal var review:Boolean = false;
        internal var round:int = -1;
        internal var thicknesses:Array;
        internal var thinnest:int;
        internal var trial:int = -1;
        internal var trialMax:int;
        internal var trialTutor:int = 3;
        internal var tutor:Boolean;
        private static var radius:Number = 128;
        private static var radiusSquared:Number = radius * radius;

        public function Model(positions:Array, roundCount:int):void
        {
            radiusSquared = radius * radius;
            targets = [];
            this.positions = positions;
            var targetCount:int = positions.length;
            for (var r:int = 1; r < roundCount; r++)
            {
                var round:Array = [];
                for (var t:int = 0; t < targetCount; t++) 
                {
                    round.push(t);
                }
                shuffle(round);
                targets = targets.concat(round);
            }
            trace("Model: " + targets);
            trialMax = targets.length;

            thicknesses = getThickness(positions);
            /**
             * TODO thin first.  or balance thicknesses.
            thinnest = thicknesses.sort(Array.NUMERIC | Array.DESCENDING);
            thinnest = thicknesses.indexOf(thinnest);
            var index:int = targets.indexOf(thinnest);
            var thatTarget:int = targets[index];
            targets.splice(index, 1);
            targets.unshift(thatTarget);
             */
        }

        private function getThickness(items:Array):Array
        {
            var areas:Array = [];
            for (var i:int = 0; i < items.length; i++) {
                var rect:Rectangle = items[i].getRect(items[i]);
                areas.push(Math.min(rect.width, rect.height));
            }
            return areas;
        }

        private function shuffle(deck:Array):void
        {
            for (var i:int = deck.length - 1; 1 <= i; i--)
            {
                var r:int = Math.random() * (i + 1);
                var swap:* = deck[i];
                deck[i] = deck[r];
                deck[r] = swap;
            }
        }

        internal function populate():void
        {
            cancel();
            trial++;
            target = targets.shift();
            if (0 == (trial % positions.length)) {
                round++;
            }
            trace("Model.populate: trial " + trial + " length " + positions.length + " round " + round + " target " + target);
            review = trialMax - 1 <= trial;
            inTrial = true;
            listening = false;
            trialTutor = Math.max(3,
                15 - 0.2 * referee.percent);
            tutor = trial <= trialTutor;
            if (!tutor) {
                referee.start();
            }
        }

        internal function cancel():void
        {
        }

        internal function truncate():void
        {
            trialMax = trial;
        }

        internal function listen():void
        {
            if (inTrial && !listening) {
                listening = true;
            }
        }

        /**
         * @return  correct
         */
        internal function answer(positionIndex:int):Boolean
        {
            var correct:Boolean = false;
            if (positionIndex <= -1) {
                throw new Error("Expected position. Got " + positionIndex);
            }
            if (complete) {
                correct = true;
            }
            else {
                correct = target == positionIndex;
                trialEnd(correct);
            }
            trace("Model.answer: " + positionIndex + " correct " + correct);
            return correct;
        }

        internal function trialEnd(correct:Boolean):void
        {
            referee.total++;
            if (correct) {
                referee.count++;
                referee.stop();
            }
            if (complete) {
                enabled = false;
            }
        }

        internal function get complete():Boolean
        {
            return trialMax <= trial;
        }
    }
}
