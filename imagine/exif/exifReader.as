package 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class  
	{
		
	}
	
}Spark project検索文字列:      ログインユーザ設定ヘルプ/GuideTrac についてホームEnglishSpark についてWikiブログフォーラムWikiタイムラインロードマップリポジトリブラウザチケットを見るチケット登録検索最終更新リビジョンログroot/as3/Exif/trunk/org/libspark/exif/ExifReader.as
特定のリビジョンを表示:  リビジョン 2258, 11.8 kB (コミッタ: kozy, コミット時期: 4 年 前)  
新規作成 

 

Line   
1 /** 
2  * The MIT License 
3  *  
4  * Copyright (c) 2009 http://www.libspark.org/ 
5  *  
6  * Permission is hereby granted, free of charge, to any person obtaining a copy 
7  * of this software and associated documentation files (the "Software"), to deal 
8  * in the Software without restriction, including without limitation the rights 
9  * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
10  * copies of the Software, and to permit persons to whom the Software is 
11  * furnished to do so, subject to the following conditions: 
12  *  
13  * The above copyright notice and this permission notice shall be included in 
14  * all copies or substantial portions of the Software. 
15  *  
16  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
17  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
18  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
19  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
20  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
21  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
22  * THE SOFTWARE. 
23  */ 
24 package nt.imagine.exif 
25 { 
26         import flash.events.EventDispatcher; 
27         import flash.utils.ByteArray; 
28         import flash.utils.Dictionary; 
29         import flash.utils.Endian; 
30          
31         import org.libspark.exif.entity.Tag; 
32         import org.libspark.exif.entity.TagDefine; 
33  
34         /** 
35          * JPEG形式のバイナリデータからExif情報を読み取るクラスです 
36          */ 
37         public class ExifReader extends EventDispatcher implements IExifReader 
38         { 
39                 /** Marker Segments - Start of Image(Start of compressed data) */  
40                 static private const SOI:uint = 0xFFD8; 
41                 ///** Marker Segments - Application Segment 1(Exif attribute information) */  
42                 //static private const APP1:uint = 0xFFE1; 
43                 ///** Marker Segments - Application Segment 2(Exif extended data) */  
44                 //static private const APP2:uint = 0xFFE2; 
45                 ///** Marker Segments - Define Quantization Table(Quantization table definition) */  
46                 //static private const DQT:uint = 0xFFDB; 
47                 ///** Marker Segments - Define Huffman Table(Huffman table definition) */  
48                 //static private const DHT:uint = 0xFFC4; 
49                 ///** Marker Segments - Define Restart Interoperability(Restart Interoperability definition) */  
50                 //static private const DRI:uint = 0xFFDD; 
51                 ///** Marker Segments - Start of Frame(Parameter data relationg to frame) */  
52                 //static private const SOF:uint = 0xFFC0; 
53                 ///** Marker Segments - Start of Scan(Parameters relating to components) */  
54                 //static private const SOS:uint = 0xFFDA; 
55                 ///** Marker Segments - End of Image(End of compressed data) */  
56                 //static private const EOI:uint = 0xFFD9; 
57                  
58                 private var _tiffTags:Array; 
59                 private var _exifTags:Array; 
60                 private var _gpsTags:Array; 
61                 private var _interoperabilityTags:Array; 
62                  
63                 private var _tagNameHash:Dictionary; 
64                  
65                 private var _tiffTagIdHash:Dictionary; 
66                 private var _exifTagIdHash:Dictionary; 
67                 private var _gpsTagIdHash:Dictionary; 
68                 private var _interoperabilityTagIdHash:Dictionary; 
69  
70                 private var _thumbnailTags:Array; 
71                 private var _thumbnailTagIdHash:Dictionary; 
72                 private var _thumbnailTagNameHash:Dictionary; 
73                 private var _thumbnailData:ByteArray; 
74  
75                 public function ExifReader(data:ByteArray=null) 
76                 { 
77                         this._tiffTags = []; 
78                         this._exifTags = []; 
79                         this._gpsTags = []; 
80                         this._interoperabilityTags = []; 
81                         this._thumbnailTags = []; 
82                         this._thumbnailData = null; 
83                          
84                         if(data)readData(data); 
85                 } 
86                  
87                 public function readData(data:ByteArray):void 
88                 { 
89                         if (checkJpeg(data) && checkExif(data)) { 
90                                 _tiffTags = parseIFD(data,20,12,TagDefine.IFD_0TH); 
91                                  
92                                 var exifTag:Tag = getTiffTagById(0x8769); 
93                                 if(exifTag)_exifTags = parseIFD(data,(exifTag.value as uint)+12,12,TagDefine.IFD_EXIF); 
94                                  
95                                 var gpsTag:Tag = getTiffTagById(0x8825); 
96                                 if(gpsTag)_gpsTags = parseIFD(data,(gpsTag.value as uint)+12,12,TagDefine.IFD_GPS); 
97                                  
98                                 var interoperabilityTag:Tag = getExifTagById(0xa005); 
99                                 if(interoperabilityTag)_interoperabilityTags = parseIFD(data,(interoperabilityTag.value as uint)+12,12,TagDefine.IFD_INTEROPERABILITY); 
100                                  
101                                 var nextIFDPointer:uint = getNextIFDPointer(data,20); 
102                                 if(nextIFDPointer>0){ 
103                                         _thumbnailTags = parseIFD(data,nextIFDPointer+12,12,TagDefine.IFD_1ST); 
104                                         var offsetTag:Tag = getThumbnailTagById(0x0201); 
105                                         var lengthTag:Tag = getThumbnailTagById(0x0202); 
106                                         if(offsetTag&&lengthTag){ 
107                                                 var thumbnailOffset:uint = offsetTag.value as uint; 
108                                                 var thumbnailLength:uint = lengthTag.value as uint; 
109                                                 _thumbnailData = new ByteArray(); 
110                                                 data.position = thumbnailOffset+12; 
111                                                 data.readBytes(_thumbnailData,0,thumbnailLength); 
112                                         } 
113                                 } 
114                                  
115                                 this.clearHash(); 
116                         } 
117                 } 
118                  
119                 private function checkJpeg(data:ByteArray):Boolean 
120                 { 
121                         /* 
122                          * Structure of JPEG 
123                          * 00-01  SOI Marker Segment 
124                          * 02-xx  APP1 
125                          * xx-xx (APP2) 
126                          * xx-xx  DQT 
127                          * xx-xx  DHT 
128                          * xx-xx (DRI) 
129                          * xx-xx  SOF 
130                          * xx-xx  SOS 
131                          * xx-xx  Compressed Data 
132                          * xx-xx  EOI 
133                          */ 
134                         data.endian = Endian.BIG_ENDIAN; 
135                         data.position = 0; 
136                         var soi:uint = data.readUnsignedShort(); 
137                         return soi==SOI; 
138                 } 
139                  
140                 private function checkExif(data:ByteArray):Boolean 
141                 { 
142                         /* 
143                          * Structure of APP1 
144                          * 02-03(2 byte)  APP1 Marker Segment 
145                          * 04-05(2 byte)  Length of field(bytes) 
146                          * 06-09(4 byte)  "Exif"(0x45,0x78,0x69,0x66) 
147                          * 10-11(2 byte)  null+Padding(0x0000) 
148                          * 12-19(8 byte)  TIFF Header 
149                          *                      12-13(2 byte)  Endian, "II"(0x4949)(little endial), "MM"(0x4D4D)(big endian) 
150                          *                      14-15(2 byte)  0x002A(fixed) 
151                          *                      16-19(4 byte)  Offset to the 0th IFD(from the TIFF Header, it is written as 0x8); 
152                          * 20-xx  0th IDF 
153                          * xx-xx  0th IFD Value 
154                          * xx-xx  1st IFD 
155                          * xx-xx  1st IFD Value 
156                          * xx-xx  1st IDF Image Data(Thumbnail) 
157                          */ 
158                         data.endian = Endian.BIG_ENDIAN; 
159                         data.position = 6; 
160                         var exif:uint = data.readUnsignedInt(); 
161                         return exif==0x45786966; 
162                 } 
163                  
164                 private function getEndian(data:ByteArray):String 
165                 { 
166                         data.position = 12; 
167                         var endian:uint = data.readUnsignedShort(); 
168                         if (endian == 0x4949) { 
169                                 return Endian.LITTLE_ENDIAN; 
170                         }else if(endian == 0x4d4d){ 
171                                 return Endian.BIG_ENDIAN; 
172                         } 
173                         return null; 
174                 } 
175                  
176                 private function parseIFD(data:ByteArray, ifdPosition:uint, tiffPosition:uint, ifdType:uint):Array 
177                 { 
178                         /* 
179                          * Structure of 0th IFD 
180                          * 20-21( 2 byte)  number of fields(UnsignedShort) 
181                          * 22-33(12 byte)  Tag(12-byte field) 
182                          *                      22-23(2 byte) Tag ID 
183                          *                      24-25(2 byte) Type(See Tag.as) 
184                          *                      26-29(4 byte) Count of value 
185                          *                      30-33(4 byte) Offset to the value(If length of value is less or equal 4 byte, the value is stored here) 
186                          * 34-45(12 byte)  Tag 
187                          * xx-xx(12 byte)  Tag 
188                          *   : 
189                          * xx-xx(12 byte)  Tag 
190                          * xx-xx( 4 byte)  Offset to the next IFD(from the TIFF Header) 
191                          */ 
192                         data.endian = getEndian(data); 
193                         data.position = ifdPosition; 
194                         var numField:uint = data.readUnsignedShort(); 
195                         var tags:Array = []; 
196                         for (var i:uint = 0; i < numField; i++) { 
197                                 var position:uint = ifdPosition + 2 + i * 12; 
198                                 tags.push(new Tag().readData(data, data.endian, position, tiffPosition, ifdType)); 
199                         } 
200                         return tags; 
201                 } 
202                  
203                 private function getNextIFDPointer(data:ByteArray, ifdPosition:uint):uint 
204                 { 
205                         data.endian = getEndian(data); 
206                         data.position = ifdPosition; 
207                         var numField:uint = data.readUnsignedShort(); 
208                         data.position = data.position+numField*12; 
209                         return data.readUnsignedShort(); 
210                 } 
211                  
212                 public function get hasExifData():Boolean 
213                 { 
214                         return this._tiffTags&&this._tiffTags.length>0; 
215                 } 
216                  
217                 public function getTiffTagById(tagid:uint):Tag 
218                 { 
219                         if(!_tiffTags)return null; 
220                          
221                         if(!_tiffTagIdHash){ 
222                                 var newDic:Dictionary = new Dictionary(true); 
223                                 var l:uint = _tiffTags.length; 
224                                 for(var i:uint=0;i<l;i++)newDic[(_tiffTags[i] as Tag).id]=(_tiffTags[i] as Tag).clone(); 
225                                 _tiffTagIdHash = newDic; 
226                         } 
227                         return _tiffTagIdHash[tagid]; 
228                 } 
229                  
230                 public function getExifTagById(tagid:uint):Tag 
231                 { 
232                         if(!_exifTags)return null; 
233                          
234                         if(!_exifTagIdHash){ 
235                                 var newDic:Dictionary = new Dictionary(true); 
236                                 var l:uint = _exifTags.length; 
237                                 for(var i:uint=0;i<l;i++)newDic[(_exifTags[i] as Tag).id]=(_exifTags[i] as Tag).clone(); 
238                                 _exifTagIdHash = newDic; 
239                         } 
240                         return _exifTagIdHash[tagid]; 
241                 } 
242                  
243                 public function getGpsTagById(tagid:uint):Tag 
244                 { 
245                         if(!_gpsTags)return null; 
246                          
247                         if(!_gpsTagIdHash){ 
248                                 var newDic:Dictionary = new Dictionary(true); 
249                                 var l:uint = _gpsTags.length; 
250                                 for(var i:uint=0;i<l;i++)newDic[(_gpsTags[i] as Tag).id]=(_gpsTags[i] as Tag).clone(); 
251                                 _gpsTagIdHash = newDic; 
252                         } 
253                         return _gpsTagIdHash[tagid]; 
254                 } 
255                  
256                 public function getInteroperabilityTagById(tagid:uint):Tag 
257                 { 
258                         if(!_interoperabilityTags)return null; 
259                          
260                         if(!_interoperabilityTagIdHash){ 
261                                 var newDic:Dictionary = new Dictionary(true); 
262                                 var l:uint = _interoperabilityTags.length; 
263                                 for(var i:uint=0;i<l;i++)newDic[(_interoperabilityTags[i] as Tag).id]=(_interoperabilityTags[i] as Tag).clone(); 
264                                 _interoperabilityTagIdHash = newDic; 
265                         } 
266                         return _interoperabilityTagIdHash[tagid]; 
267                 } 
268                  
269                 public function getTagByName(name:String):Tag 
270                 { 
271                         if(!_tiffTags)return null; 
272                          
273                         if(!_tagNameHash){ 
274                                 var newDic:Dictionary = new Dictionary(true); 
275                                 var tags:Array = allTags; 
276                                 var l:uint = tags.length; 
277                                 for(var i:uint=0;i<l;i++)newDic[(tags[i] as Tag).name]=tags[i] as Tag; 
278                                 _tagNameHash = newDic; 
279                         } 
280                         return _tagNameHash[name]; 
281                 } 
282  
283                 /** internal use only */                 
284                 private function clearHash():void 
285                 { 
286                         this._tiffTagIdHash = null; 
287                         this._exifTagIdHash = null; 
288                         this._gpsTagIdHash = null; 
289                         this._interoperabilityTagIdHash = null; 
290                         this._tagNameHash = null; 
291                         this._thumbnailTagIdHash = null; 
292                         this._thumbnailTagNameHash = null; 
293                 } 
294                  
295                 public function get allTags():Array 
296                 { 
297                         return tiffTags.concat(exifTags).concat(gpsTags).concat(interoperabilityTags); 
298                 } 
299                  
300                 public function get tiffTags():Array 
301                 { 
302                         if(!_tiffTags)return []; 
303  
304                         var newAry:Array = []; 
305                         var l:uint = _tiffTags.length; 
306                         for(var i:uint=0;i<l;i++)newAry[i]=(_tiffTags[i] as Tag).clone(); 
307                         return newAry; 
308                 } 
309                  
310                 public function get exifTags():Array 
311                 { 
312                         if(!_exifTags)return []; 
313  
314                         var newAry:Array = []; 
315                         var l:uint = _exifTags.length; 
316                         for(var i:uint=0;i<l;i++)newAry[i]=(_exifTags[i] as Tag).clone(); 
317                         return newAry; 
318                 } 
319                  
320                 public function get gpsTags():Array 
321                 { 
322                         if(!_gpsTags)return []; 
323  
324                         var newAry:Array = []; 
325                         var l:uint = _gpsTags.length; 
326                         for(var i:uint=0;i<l;i++)newAry[i]=(_gpsTags[i] as Tag).clone(); 
327                         return newAry; 
328                 } 
329                  
330                 public function get interoperabilityTags():Array 
331                 { 
332                         if(!_interoperabilityTags)return []; 
333  
334                         var newAry:Array = []; 
335                         var l:uint = _interoperabilityTags.length; 
336                         for(var i:uint=0;i<l;i++)newAry[i]=(_interoperabilityTags[i] as Tag).clone(); 
337                         return newAry; 
338                 } 
339                  
340                 public function get hasThumbnail():Boolean 
341                 { 
342                         return _thumbnailData&&_thumbnailData.length>0; 
343                 } 
344                  
345                 public function get thumbnailTags():Array 
346                 { 
347                         if(!_thumbnailTags)return []; 
348  
349                         var newAry:Array = []; 
350                         var l:uint = _thumbnailTags.length; 
351                         for(var i:uint=0;i<l;i++)newAry[i]=(_thumbnailTags[i] as Tag).clone(); 
352                         return newAry; 
353                 } 
354  
355                 public function getThumbnailTagById(tagid:uint):Tag 
356                 { 
357                         if(!_thumbnailTags)return null; 
358                          
359                         if(!_thumbnailTagIdHash){ 
360                                 var newDic:Dictionary = new Dictionary(true); 
361                                 var l:uint = _thumbnailTags.length; 
362                                 for(var i:uint=0;i<l;i++)newDic[(_thumbnailTags[i] as Tag).id]=(_thumbnailTags[i] as Tag).clone(); 
363                                 _thumbnailTagIdHash = newDic; 
364                         } 
365                         return _thumbnailTagIdHash[tagid]; 
366                 } 
367  
368                 public function getThumbnailTagByName(name:String):Tag 
369                 { 
370                         if(!_thumbnailTags)return null; 
371                          
372                         if(!_thumbnailTagNameHash){ 
373                                 var newDic:Dictionary = new Dictionary(true); 
374                                 var l:uint = _thumbnailTags.length; 
375                                 for(var i:uint=0;i<l;i++)newDic[(_thumbnailTags[i] as Tag).name]=(_thumbnailTags[i] as Tag).clone(); 
376                                 _thumbnailTagNameHash = newDic; 
377                         } 
378                         return _thumbnailTagNameHash[name]; 
379                 } 
380                  
381                 public function get thumbnailData():ByteArray 
382                 { 
383                         return _thumbnailData; 
384                 } 
385                  
386         } 
387 } 

Note: リポジトリブラウザについてのヘルプは TracBrowser を参照してください。 
     異なるフォーマットでダウンロード:
Original Format
--------------------------------------------------------------------------------
 
Powered by Trac 0.10.3.1
By Edgewall Software. 
Translated by インタアクト株式会社 
 
 
