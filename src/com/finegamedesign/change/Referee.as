package com.finegamedesign.change
{
    import flash.utils.getTimer;

    /**
     * 2014-08-24 End.  Kerry at The MADE expects to score.
     */
    internal final class Referee
    {
        internal var count:int = 0;
        internal var total:int = 0;
        private var millisecondsTotal:int = 0;
        private var millisecondsStart:int = 0;
        private var playing:Boolean = false;

        public function Referee()
        {
        }

        /**
         * Percent correct - average reaction time.
         */
        internal function get score():int
        {
            var millisecondPerSecond:int = 1000;
            return percent - seconds;
        }

        internal function get percent():int
        {
            return Math.round(100 * count / total);
        }

        internal function start():void
        {
            if (!playing) {
                playing = true;
                millisecondsStart = getTimer();
            }
        }

        internal function stop():void
        {
            if (playing) {
                playing = false;
                var milliseconds:int = getTimer() - millisecondsStart;
                millisecondsTotal += milliseconds;
                trace("Referee.stop: score " + score + " milliseconds " 
                    + milliseconds + " count " + count);
            }
        }

        private function get seconds():int
        {
            return Math.ceil(millisecondsTotal / 1000 / Math.max(1, count));
        }

        /**
         * 2014-08-27 Jennifer Russ may understand number by reading format like "1:20".
         * Average minutes and seconds.
         */
        internal function get minutes():String
        {
            const secPerMin:int = 60;
            var _seconds:int = seconds;
            var min:int = _seconds / secPerMin;
            var sec:int = _seconds % secPerMin;
            var lead:String = sec < 10 ? "0" : "";
            return min + ":" + lead + sec;
        }
    }
}
