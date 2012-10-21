/**
*	
*/
package game.entities
{	
	import com.greensock.TweenMax;
	import game.data.Player;
	import game.states.mainStates.GameplayState;
	import game.utils.AssetLibrary;
	import game.utils.GeomUtils;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.TextureSmoothing;

	/**
	*	
	*/
	public class Powerup extends Entity
	{
		public static const TYPE_STREAM:String = "stream";
		public static const TYPE_SPREAD:String = "spread";
		public static const TYPE_SPHERE:String = "sphere";
		public static const TYPE_QUICKBULLET:String = "quickbullet";
		public static const TYPE_SILVERBULLET:String = "silverbullet";

		public static const TYPES:Array = 
		[
			TYPE_STREAM,
			TYPE_SPREAD,
			TYPE_SPHERE,
			TYPE_QUICKBULLET,
			TYPE_SILVERBULLET
		];



		public static var typeGraphics:Object = {};
		public static function initGraphicRefs():void
		{
			for (var powerupIndex:int = 0; powerupIndex < Powerup.TYPES.length; powerupIndex++)
			{
				var type:String = Powerup.TYPES[powerupIndex];

				var popupSprite:Sprite = new Sprite();
				var popupImage:Image;
				var iconSprite:Sprite = new Sprite();
				var iconImage:Image;
				switch(type)
				{
					case Powerup.TYPE_STREAM: 			popupImage = new Image(AssetLibrary.clickThroughpopupTexture);	iconImage = new Image(AssetLibrary.clickThroughTexture);	break;
					case Powerup.TYPE_SPHERE: 			popupImage = new Image(AssetLibrary.metricsPopupTexture);		iconImage = new Image(AssetLibrary.metricsTexture);	break;
					case Powerup.TYPE_SPREAD: 			popupImage = new Image(AssetLibrary.splitTestBmpTexture);		iconImage = new Image(AssetLibrary.splitTexture);	break;
					case Powerup.TYPE_QUICKBULLET: 		popupImage = new Image(AssetLibrary.clickThroughpopupTexture);		iconImage = new Image(AssetLibrary.clickThroughTexture);	break;
					case Powerup.TYPE_SILVERBULLET: 	popupImage = new Image(AssetLibrary.clickThroughpopupTexture);		iconImage = new Image(AssetLibrary.clickThroughTexture);	break;
				}

				if (popupImage && iconImage)
				{
					popupImage.x = 343/2;
					popupImage.y = 102/2;
					popupSprite.addChild(popupImage);
					iconImage.x = -11;
					iconImage.y = -16;
					iconSprite.addChild(iconImage);
					typeGraphics[type] = {popup:popupSprite, icon:iconSprite};
				}
			}
		}

		private var _id:String;
		public function get id():String { return _id; }
		public function set id(value:String):void
		{
			_id = value;
			var t:Object = typeGraphics[_id];
			if (t && t.icon)
			{
				_sprite.addChild(t.icon);
			}
			else
			{
				_bodyImage = new Image(AssetLibrary.placeholderPowerupTexture);
				_bodyImage.smoothing = TextureSmoothing.NONE;
				_sprite.addChild(_bodyImage);
			}
		}
		
		/**
		*	@constructor
		*/
		public function Powerup():void
		{
			super();

			rect.width = 22;
			rect.height = 32;

			// moved to set id()
			//_bodyImage = new Image(AssetLibrary.placeholderPowerupTexture);
			//_bodyImage.smoothing = TextureSmoothing.NONE;
			//_sprite.addChild(_bodyImage);

			TweenMax.to(_sprite, 0.2, {scaleX:1.1, scaleY:1.1, yoyo:true, repeat:-1});
		}
		
		override public function takeTurn():void
		{
			// if we're overlapping any heroes, have the hero pick me up.
			var touchingHeroes:Array = getTouchingPlayers();

			// just give it to the first hero.
			if (touchingHeroes.length > 0)
			{
				_gameState.acquirePowerup(touchingHeroes[0].avatar, this);
			}
		}
		
	}
}