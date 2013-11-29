Exif  修改exif库，能准确获得度分秒信息
====

exif



					
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
