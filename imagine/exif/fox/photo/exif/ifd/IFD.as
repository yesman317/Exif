package nt.imagine.exif.fox.photo.exif.ifd
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;

	/**
	 *		Bytes 0-1 Tag
		Bytes 2-3 Type
		Bytes 4-7 Count
		Bytes 8-11 Value Offset
	 * @author Liu
	 *
	 */
	public class IFD
	{


		/**
		 *Each tag is assigned a unique 2-byte number to identify the field. The tag numbers in the Exif 0th IFD and 1st IFD
are all the same as the TIFF tag numbers.
	 */
		public var tag:uint

		public var type:uint
		/**
		 *The number of values. It should be noted carefully that the count is not the sum of the bytes. In the case of one value
of SHORT (16 bits), for example, the count is '1' even though it is 2 bytes.
	 */
		public var count:uint
		/**
		 *This tag records the offset from the start of the TIFF header to the position where the value itself is recorded. In
cases where the value fits in 4 bytes, the value itself is recorded. If the value is smaller than 4 bytes, the value is
stored in the 4-byte area starting from the left, i.e., from the lower end of the byte offset area. For example, in big
endian format, if the type is SHORT and the value is 1, it is recorded as 00010000.H.
Note that field Interoperability must be recorded in sequence starting from the smallest tag number. There is no
stipulation regarding the order or position of tag value (Value) recording.
	 */
		public var offset:uint

		public var data:IFDValue;
		
		//sean
		public var isGps:Boolean;
		

		public function IFD()
		{
			data=new IFDValue();
		}

		public function read(input:ByteArray,isGps:Boolean=false):void
		{
			this.isGps = isGps;
			
			var pos:uint=input.position;
			tag=input.readUnsignedShort();
			type=input.readUnsignedShort();
			count=input.readUnsignedInt();
			data.tag = tag;
			readValue(input);
			input.position=pos + 12;
		}
		
		/*offset=tiff.readUnsignedInt();
						tiff.position=offset;
						value = tiff.readUTFBytes(count);*/
						
						/**
						 * offset730
							count7436
							value%
							
							为软件开发人员提供的更多信息

如果 Maker Note 标记被 Windows Vista 或 Windows XP 重定位，EXIF Maker Note 标记 (37500) 
将自动更新以引用新位置。此外，Windows Vista 和 Windows XP 会在 EXIF OffsetSchema 标记 (59933)
中记录原来的位置与新位置之间的偏移量。如果 Maker Note 标记中包含相对引用，开发人员可以将 OffsetSchema 
标记中的值与原始引用相加，以找到正确的信息。
						 */
		public function readValue(tiff:ByteArray):void
		{
			var value:Object = null;
			
			switch (type)
			{
				case 1: //取全整byte类型(Byte)
					value=tiff.readUnsignedByte();
					break;
				case 2: //取ASCII(ASCII)
					if (count <= 4)
					{
						value=tiff.readUTFBytes(count);
					}
					else
					{
						offset=tiff.readUnsignedInt();
						tiff.position=offset;
						value=tiff.readUTFBytes(count);
					}
					break;
				case 3: //取全整uint类型(SHORT)
					value=tiff.readUnsignedShort();
					break;
				case 4: //取全整INT类型(LONG)
					value=tiff.readUnsignedInt();
					break;
				case 5: //取全整INT类型分数(RATIONAL)
					offset=tiff.readUnsignedInt();
					tiff.position = offset;
					value = tiff.readUnsignedInt() + "/" + tiff.readUnsignedInt();
					if (isGps && (tag == 2 || tag == 4))
					{
						var value2:Array = [];
						
						var molecule2:int =  tiff.readUnsignedInt();
						var denominator2:int =  tiff.readUnsignedInt();
						
						var molecule3:int =  tiff.readUnsignedInt();
						var denominator3:int =  tiff.readUnsignedInt();
						
						value2.push(value);
						
						var second:Number = molecule2 / denominator2;
						if (second is int)
						{
							value2.push( molecule2 + "/" + denominator2, molecule3 + "/" + denominator3);
						}
						else
						{
							value2.push( molecule2 + "/" + denominator2);
						}
						value = value2.join(",");
					}
					break;
				case 7: //取任意字节(UNDEFINED)
					//trace("countcount"+count);
					if (count <= 4)
					{
						value=tiff.readUTFBytes(count);
					}
					else
					{
						offset=tiff.readUnsignedInt();
						tiff.position=offset;
						value = tiff.readUTFBytes(count);
					}
					break;
				case 9: //取INT类型(SLONG)
					value=tiff.readInt();
					break;
				case 10: //取INT类型分数(SRATIONAL)
					offset=tiff.readUnsignedInt();
					tiff.position=offset;
					value=tiff.readInt() + "/" + tiff.readInt();
					break;
				
				default :break;
			}
			
			this.data.value=value;
		}
		
	
		public function toString():String
		{
			return "[IFD: tag=" + tag + ",\ttype=" + type + ",\tcount=" + count + ",\toffset=0x" + offset.toString(16) + "]";
		}
	}
}
