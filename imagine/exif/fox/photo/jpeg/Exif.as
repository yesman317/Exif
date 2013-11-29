package nt.imagine.exif.fox.photo.jpeg
{
	import nt.imagine.exif.fox.photo.exif.ifd.IFD;
	import nt.imagine.exif.fox.photo.exif.UsefulExif;
	import nt.imagine.exif.fox.photo.exif.ifd.IFDValue;
	public class Exif
	{
		public var tags:Array = [];
		public var userful:UsefulExif=new UsefulExif();
		
		public function Exif()
		{
		}
		
		public function initUseFul():void
		{
			//拍照日期
			var tag:IFDValue = this.findTagById(36867);
			if(tag){
				var t:String = ""+tag.value;
				userful.date = t;
			}else if((tag=this.findTagById(36868))!=null){
				var tt:String = ""+tag.value;
				userful.date = tt;
			}else if((tag=this.findTagById(306))!=null){
				var t2:String = ""+tag.value;
				userful.date =  t2;
			}
			//高度
			tag = this.findTagById(40963);
			if(tag){
				userful.height = int(tag.value);
			}
			//宽度
			tag = this.findTagById(40962);
			if(tag){
				userful.width = int(tag.value);
			}
			//Orientation  274 图片方向
			tag = this.findTagById(274);
			if(tag){
				userful.orientation = int(tag.value);
			}
			//Model 272  设备制造商
			tag = this.findTagById(272);
			if(tag){
				userful.model = ""+(tag.value);
			}
			//Make 271  使用设备
			tag = this.findTagById(271);
			if(tag){
				userful.make = ""+(tag.value);
			}
			//33434 曝光时间
			tag = this.findTagById(33434);
			if(tag){
				userful.baoguang = ""+(tag.value);
			}
			//33437 光圈
			tag = this.findTagById(33437);
			if(tag){
				userful.av = ""+(tag.value);
			}
			//927c == 37500
			/*tag = this.findTagById(37500);
			
			Utility.jsTrace("927c "+tag.value);
			if(tag){
				userful.av = ""+(tag.value);
			}*/
			
		}
		
		public function findTagById(id:uint):IFDValue{
			for each (var i:IFDValue in tags) 
			{
				if(i.tag==id){
					return i;
				}
			}
			return null;
		}
	}
}