/**
*	
*/
package game.states.mainStates
{	
	import Game.*;
	
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import game.data.GameData;
	import game.data.GlobalData;
	import game.data.Player;
	import game.debug.ScreenPrint;
	import game.entities.*;
	import game.entities.Bullet;
	import game.entities.controllers.*;
	import game.states.IState;
	import game.states.mainStates.*;
	import game.ui.Hud;
	import game.utils.AssetLibrary;
	import game.utils.FrameTime;
	import game.utils.InputManager;
	
	import starling.core.Starling;
	import starling.extensions.ParticleDesignerPS;
	import starling.text.TextField;
	import starling.textures.Texture;

	/**
	*	this is the state the app is in while the player is mid-game
	*/
	public class GameplayState extends MainState implements IState 
	{
		public static var instance:GameplayState;

		override public function get name():String{ return "GameState"; }

		private var _hud:Hud;

		private var _activePlayerTotal:int = 0;
		private var _activePlayers:Vector.<Player> = new Vector.<Player>();
		public function get activePlayers():Vector.<Player> { return _activePlayers; }
		/**
		* this hash uses an entity as a key, and contains a reference to the corresponding Player object if it exists
		*/
		private var _playerDataForEntity:Dictionary = new Dictionary();
		

		private var _powerups:Dictionary = new Dictionary();
		private var _bullets:Dictionary = new Dictionary();

		/**
		*	@constructor
		*/
		public function GameplayState(game:Game):void
		{
			// ghetto singleton setup, just get it going.
			if (!instance) instance = this;

			super(game);
		}
				
		override public function enter():void
		{
			super.enter();

			// build up a list of active players so we know who is playing the game.
			var heroTotal:int = _game.gameData.players.length;
			for (var heroIndex:int = 0; heroIndex < heroTotal; heroIndex++)
			{
				var playerData:Player = _game.gameData.players[heroIndex];
				if (playerData.playerType != Player.TYPE_INVALID)
				{
					_activePlayers.push(playerData);
				}
			}

			//========================================================
			// set up all the active players' avatars
			//========================================================
			_activePlayerTotal = _activePlayers.length;
			for (var activePlayerIndex:int = 0; activePlayerIndex < _activePlayerTotal; activePlayerIndex++)
			{
				var activePlayer:Player = _activePlayers[activePlayerIndex];

				// TODO :: set up hero class based on character selection
				//if (activePlayer.characterType == ANGRY_GORILLA) activePlayer.avatar = new Gorilla();
				activePlayer.avatar = new Hero() as LivingEntity;
				activePlayer.avatar.controller = EntityController.getControllerType(LocalPlayerController);
				activePlayer.avatar.x = GlobalData.HALF_SCENE_WIDTH;
				activePlayer.avatar.y = GlobalData.HALF_SCENE_HEIGHT;

				_playerDataForEntity[activePlayer.avatar] = activePlayer;
			}
			
			//========================================================
			// enemy test.  
			// TODO :: refactor this so there's an add enemy function somewhere that's easy to access.
			//========================================================
			//for (var enemyIndex:int = 0; enemyIndex < 1; enemyIndex++)
			//{
			//	var enemy:Enemy = new Enemy();
//
			//	enemy.target = _activePlayers[0].avatar;
			//	enemy.controller = EntityController.getControllerType(AIControllerBasic);
			//	enemy.x = enemyIndex % 2 == 0 ? GlobalData.SCENE_WIDTH : 0;  //left side or right side
			//	enemy.y = Math.random() * GlobalData.HALF_SCENE_HEIGHT;
			//	_game.gameLayer.addChild(enemy.sprite);
			//	_enemies[enemy] = enemy;// it's a dictionary so we can pluck things out in constant time
			//}

			//========================================================
			// add the heroes to the stage, on top of the enemies for now.
			//========================================================
			for (activePlayerIndex = 0; activePlayerIndex < _activePlayerTotal; activePlayerIndex++)
			{
				_game.gameLayer.addChild(_activePlayers[activePlayerIndex].avatar.sprite);
			}

			//========================================================
			// add some powerups
			//========================================================
			for (var powerupIndex:int = 0; powerupIndex < 2; powerupIndex++)
			{
				var powerup:Powerup = new Powerup();
				powerup.x = int(Math.random() * GlobalData.SCENE_WIDTH);
				powerup.y = int(Math.random() * GlobalData.SCENE_HEIGHT);
				powerup.id = "quickbullet";
				_game.gameLayer.addChild(powerup.sprite);
				_powerups[powerup] = powerup; 	// it's a dictionary so we can pluck things out in constant time
			}

			/*
			// bullet test.
			var bullet:Bullet = new Bullet();
			bullet.sprite.x = 50;
			bullet.sprite.y = 50;
			_game.gameLayer.addChild(bullet.sprite);
			*/
			
			// init ui layer.
			_hud = new Hud();
			_game.uiLayer.addChild(_hud);
		}

		override public function exit():void
		{
			super.exit();

			// clean up ui
			if (_hud && _hud.parent)
			{
				_hud.parent.removeChild(_hud);
				_hud = null;
			}
			
			// clean up hero
			for (var activePlayerIndex:int = 0; activePlayerIndex < _activePlayerTotal; activePlayerIndex++)
			while(_activePlayers.length > 0)
			{
				var player:Player = _activePlayers.pop();
				if (player && player.avatar.sprite.parent)
				{
					player.avatar.sprite.removeChild(player.avatar.sprite);
				}	
			}
			
			// cleanup enemies
			while(_enemies.length > 0)
			{
				var enemy:Enemy = _enemies.pop();
				if (enemy && enemy.sprite.parent)
				{
					enemy.sprite.removeChild(enemy.sprite);
				}
			}
		}

		override public function update(dt:Number):void
		{
			heroTurn();
			enemyTurn();
			bulletTurn();
			powerupTurn();
			enemyRespawnHandler();
		}
		
		//========================================================
		// bullets
		//========================================================
		public function spawnBullet(bullet:Bullet):void
		{			
			//var bullet:Bullet = new Bullet(shooter, x, y, angle);
			_bullets[bullet] = bullet;
			_game.gameLayer.addChild(bullet.sprite);	
		}
		
		private function bulletTurn():void
		{
			for (var i:* in _bullets)
			{
				var bullet:Bullet = _bullets[i];
				bullet.update();
			}
		}

		public function bulletHitEnemy(bullet:Bullet, enemy:Enemy):Boolean
		{
			removeBullet(bullet);

			if (!enemy.invincible)
			{
				enemy.health -= bullet.damage;

				if (enemy.health <= 0)
				{
					removeEnemy(enemy);

					// log kill in player data here!
					if (_playerDataForEntity[bullet.shooter])
					{
						var shootingPlayer:Player = _playerDataForEntity[bullet.shooter];
						shootingPlayer.kills++;
					}
				
					// update hud?
				}

				// invuln period?
				//enemy.invincible = true;// make invulnerable for a bit so they dont' take spam damage
				//setTimeout(turnOffPlayerDamageInvincibility, GlobalData.PLAYER_DAMAGED_INVINCIBILITY_DURATION, player);
			}

			return true;
		}

		public function removeBullet(bullet:Bullet):void
		{
			if(_bullets[bullet])
			{
				bullet.cleanupForRemoval();
				delete _bullets[bullet];
			}
		}

		//========================================================
		// hero
		//========================================================
		private function heroTurn():void
		{
			for (var activePlayerIndex:int = 0; activePlayerIndex < _activePlayerTotal; activePlayerIndex++)
			{
				var activePlayer:Player = _activePlayers[activePlayerIndex];
				activePlayer.avatar.takeTurn();

				ScreenPrint.show("Kills: " + activePlayer.kills);
			}
		}

		//========================================================
		// enemies
		//========================================================
		private var _enemies:Dictionary = new Dictionary();
		public function get enemies():Dictionary { return _enemies; }
		private var _onScreenEnemyCount:int = 0;
		private var _enemyRespawnCooldownInSeconds:Number = 0.0;

		/**
		* tries to figure out if we should spawn a new enemy in.
		*/
		private function enemyRespawnHandler():void
		{
			_enemyRespawnCooldownInSeconds -= FrameTime.timeDiffInSeconds;
			if (_enemyRespawnCooldownInSeconds <= 0)
			{
				var enemyCountThatCanSpawn:int = GlobalData.MAX_ENEMIES_ON_SCREEN - _onScreenEnemyCount;
				if (enemyCountThatCanSpawn > 0)
				{
					_enemyRespawnCooldownInSeconds = Math.random() * 2 + 0.2;

					// most to spawn at once right now is 3.
					// probably want to scale that based on the intensity of the action right now.
					var enemiesToSpawn:int = Math.min(enemyCountThatCanSpawn, 3);
					for (var enemyIndex:int = 0; enemyIndex < enemiesToSpawn; enemyIndex++)
					{
						// just spawn a basic enemy for now.
						spawnEnemy(Enemy);
					}
				}
			}
		}

		private function spawnEnemy(klass:Class):Enemy
		{
			var enemy:* = new klass() as Enemy;

			if (enemy)
			{	
				// should leave targeting up to the AI, but that's a stretch feature
				enemy.target = _activePlayers[0].avatar;
	
				// pick a random AI maybe?
				enemy.controller = EntityController.getControllerType(AIControllerBasic);
	
				// put them at the edge of the screen
				enemy.x = Math.random() > 0.5 ? GlobalData.SCENE_WIDTH : 0;  //left side or right side
				enemy.y = Math.random() * GlobalData.HALF_SCENE_HEIGHT;
	
				// add em!
				_game.gameLayer.addChild(enemy.sprite);
				_enemies[enemy] = enemy;// it's a dictionary so we can pluck things out in constant time
	
				// update how many enemies we have onscreen
				_onScreenEnemyCount++;
	
				return enemy;
			}
			return null;
		}
		private function enemyTurn():void
		{
			for each (var enemy:Enemy in _enemies)
			{
				enemy.takeTurn();
			}
		}

		public function attackPlayer(attacker:LivingEntity, player:Player):void
		{
			if (!player.avatar.invincible)
			{
				var hero:Hero = Hero(player.avatar);
				hero.hit();
				player.avatar.health -= attacker.meleeDamage;

				// invuln period
				player.avatar.invincible = true;// make invulnerable for a bit so they dont' take spam damage
				setTimeout(turnOffPlayerDamageInvincibility, GlobalData.PLAYER_DAMAGED_INVINCIBILITY_DURATION, player);

				// update hud!
				_hud.setPlayerHealth(player.playerIndex, player.avatar.health);
			}
		}

		private function turnOffPlayerDamageInvincibility(player:Player):void
		{
			player.avatar.invincible = false;
		}

		private function removeEnemy(enemy:Enemy):void
		{
			if(_enemies[enemy])
			{
				// update how many enemies are on screen
				_onScreenEnemyCount--;

				enemy.cleanupForRemoval();
				delete _enemies[enemy];
			}
		}

		//========================================================
		// powerups
		//========================================================
		private function powerupTurn():void
		{
			for each (var powerup:Powerup in _powerups)
			{
				powerup.takeTurn();
			}
		}

		public function acquirePowerup(livingEntity:LivingEntity, powerup:Powerup):void
		{
			trace("acquire powerup!");
			livingEntity.addPowerup(powerup);
			removePowerup(powerup);

			// play cool effect
		}

		public function removePowerup(powerup:Powerup):void
		{
			if (_powerups[powerup])
			{
				powerup.cleanupForRemoval();
				delete _powerups[powerup];
			}
		}
	}
}