package strategy.model.resources {
		
	import strategy.model.base.IGameFactorModel;
	
	public interface ICalendarModel extends IGameFactorModel {
		
		function get daysPassed():uint;
		
	}
}