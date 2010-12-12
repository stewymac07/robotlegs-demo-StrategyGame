package strategy.model.resources {
	
	import org.robotlegs.mvcs.Actor;
	import strategy.model.base.GameFactorModel;
	import strategy.model.resources.IWorker;
	import strategy.model.base.IMarketVariationModel;
	import strategy.model.base.MarketVariationModel;
	import strategy.model.markets.ILabourPriceMarket;
	import strategy.controller.events.ResourceStatusEvent;
	import strategy.model.resources.TempWorker;
	import strategy.model.transactions.WorkerProductivityVO;
	
	public class LabourModel extends MarketVariationModel implements ILabourModel {
		
		protected var _team:Vector.<IWorker>;
		
		protected var _labourPriceMarket:ILabourPriceMarket;
		
		public function LabourModel() {
		}            
		
		//---------------------------------------
		// ILabourModel Implementation
		//---------------------------------------

		//import strategy.model.resources.ILabourModel;
		public function get teamSize():uint
		{
			return team.length;
		}

		public function set teamSize(value:uint):void
		{
			if(value != team.length)
			{
				adjustTeamSize(value);
				dispatchTeamUpdate();
		    }
		}
		
		public function appendWorkers(workers:Vector.<WorkerProductivityVO>):void
		{
			if((workers == null )||(workers.length==0))
			{
				return;
			}
			
			var iLength:uint = workers.length;
			for (var i:int = 0; i < iLength; i++)
			{
				var nextWorkerProductivty:WorkerProductivityVO = workers[i];
				var tempWorker:IWorker = createTempWorker(nextWorkerProductivty);
				team.push(tempWorker);
			}
			dispatchTeamUpdate();
		}
		
		public function removeTempWorkers():void
		{
			var iLength:uint = team.length;
			for (var i:int = iLength-1; i >= 0; i--)
			{
				if(team[i] is TempWorker)
				{
					team.pop();
				}
			}
		}

		public override function get currentValue():Number
		{
		    var totalBuilt:Number = 0;
			var iLength:uint = team.length;
			for (var i:int = 0; i < iLength; i++)
			{
				var nextWorker:IWorker = team[i];
				trace("adding blocks from: " + nextWorker + " -> " + nextWorker.currentValue);
				totalBuilt += nextWorker.currentValue;
			}
			
			return totalBuilt;
		}
		
		public override function move():void
		{
			var iLength:uint = team.length;
			for (var i:int = 0; i < iLength; i++)
		   	{
		   		var nextWorker:IWorker = team[i];
				configureWorker(nextWorker);
				nextWorker.move();
		   	}
		}
		
		public function get team():Vector.<IWorker>
		{
			return _team ||= new Vector.<IWorker>();
		}
		
		public function get teamCost():Number
		{
			var totalCost:Number = 0;
			var iLength:uint = team.length;
			for (var i:int = 0; i < iLength; i++)
			{
			    var nextWorker:IWorker = team[i];
				trace("adding pay for: " + nextWorker + " -> " + nextWorker.pay);
		   		totalCost += nextWorker.pay;
			}
			
			return totalCost;
		}
		
		public function adjustTeamEnergy(value:Number):void
		{
			for each (var worker:IWorker in team)
			{
				worker.adjustEnergyLevel(value);
			}
		}
		                                                          
		[Inject]
		public function set labourPriceMarket(value:ILabourPriceMarket):void
		{
			_labourPriceMarket = value;
		}
		
		
		protected function adjustTeamSize(requiredTeamSize:uint):void
		{
			while(team.length > requiredTeamSize)
			{
				team.pop();
			}
			while(team.length < requiredTeamSize)
			{
				team.push(newWorker);
			}
		}
		
		protected function get newWorker():IWorker
		{
			var worker:IWorker = new Worker();
			configureWorker(worker);
			worker.pay = _labourPriceMarket.currentValue;
			worker.energyLevel = 100; 
			
			return worker;
		}
		
		protected function createTempWorker(workerVO:WorkerProductivityVO):IWorker
		{
			var worker:IWorker = new TempWorker();
			worker.max = workerVO.stonesBuilt + this.volatility;
			worker.min = workerVO.stonesBuilt - this.volatility;
			worker.pay = workerVO.wagesPaid;
			
			return worker;
		}
		
		protected function configureWorker(worker:IWorker):void
		{
			worker.max = this.max;
			worker.min = this.min;
			worker.volatility = this.volatility;
		}
		
		protected function dispatchTeamUpdate():void
		{
			var evt:ResourceStatusEvent = new ResourceStatusEvent(ResourceStatusEvent.TEAM_SIZE_UPDATED, team.length, 0);
			dispatch(evt);
		}   
		
		                     
	}
}