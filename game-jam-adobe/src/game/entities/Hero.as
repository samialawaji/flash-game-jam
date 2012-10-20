/**
*	
*/
package game.entities
{	
	import game.utils.AssetLibrary;
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	*	things that need to live
	*/
	public class Hero extends LivingEntity
	{
		/**
		*	@constructor
		*/
		public function Hero():void
		{
			// init game layer.
			_bodyImage = new Image(AssetLibrary.heroTextureIdle);
			_sprite.addChild(_bodyImage);
		}
		
		
	}
}