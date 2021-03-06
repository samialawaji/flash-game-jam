/**
*	
*/
package game.data
{	
	/**
	*	
	*/
	public class GlobalData 
	{
		public static const MODE_DEBUG:int = 0;
		public static const MODE_RELEASE:int = 1;
		public static const CURRENT_MODE:int = MODE_RELEASE;
		public static function get RELEASE():Boolean { return CURRENT_MODE == MODE_RELEASE; }
		public static function get DEBUG():Boolean { return CURRENT_MODE == MODE_DEBUG; }

		public static const SCENE_WIDTH:int = 450;
		public static const SCENE_HEIGHT:int = 400;
		public static const SCENE_SCALE:Number = 2;
		public static const HALF_SCENE_WIDTH:int = SCENE_WIDTH / 2;
		public static const HALF_SCENE_HEIGHT:int = SCENE_HEIGHT / 2;
		public static const STAGE_ROOF_EDGE:int = 78;

		//========================================================
		// game tweaks
		//========================================================
		public static const PLAYER_DAMAGED_INVINCIBILITY_DURATION:int = 1000;// milliseconds
		public static const MAX_ENEMIES_ON_SCREEN:int = 100;
		public static const POWERUP_STACK_SIZE:uint = 1;
	}
}