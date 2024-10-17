/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import E5Data

@Observable class TrackStatus: NSObject{
    
    static var shared = TrackStatus()
    
    var trackpoints: TrackpointList
    var distance : CGFloat
    var isRecording: Bool
    
    var isTracking: Bool{
        trackpoints.count > 0
    }
    
    var startTime : Date{
        trackpoints.first?.timestamp ?? Date()
    }
    var endTime :Date{
        trackpoints.last?.timestamp ?? Date()
    }
    
    var duration: Range<Date>{
        startTime..<endTime
    }
    
    var durationString: String{
        duration.formatted(.timeDuration)
    }
    
    override init(){
        trackpoints = TrackpointList()
        distance = 0
        isRecording = false
    }
    
    func startTracking(at location: CLLocation){
        addTrackpoint(from: location)
        isRecording = true
    }
    
    func startRecording(){
        isRecording = true
    }
    
    func stopRecording(){
        isRecording = false
    }
    
    func resumeRecording(){
        isRecording = true
    }
    
    func saveTrack(){
        isRecording = false
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(trackpoints){
            if let json = String(data:data, encoding: .utf8){
                PhoneConnector.instance.saveTrack(json: json){ success in
                    if success{
                        self.trackpoints.removeAll()
                    }
                }
            }
        }
    }
    
    func cancelTrack(){
        isRecording = false
        trackpoints.removeAll()
    }
    
    func addTrackpoint(from location: CLLocation){
        let tp = Trackpoint(location: location)
        if trackpoints.isEmpty{
            trackpoints.append(tp)
            Log.info("starting track at \(tp.coordinate.debugString)")
            return
        }
        let previousTrackpoint = trackpoints.last!
        let timeDiff = previousTrackpoint.timestamp.distance(to: tp.timestamp)
        if timeDiff < Preferences.shared.trackpointInterval{
            return
        }
        let horizontalDiff = previousTrackpoint.coordinate.distance(to: tp.coordinate)
        if horizontalDiff < Preferences.shared.minHorizontalTrackpointDistance{
            return
        }
        Log.info("adding trackpoint at \(tp.coordinate.debugString)")
        trackpoints.append(tp)
        distance += horizontalDiff
        trackpoints.append(Trackpoint(coordinate: location.coordinate, altitude: location.altitude, timestamp: location.timestamp))
        
    }
    
}

extension TrackStatus{
    
    static var sample: String =
    """
[
  {
    'altitude' : 1464.6821975708008,
    'latitude' : 46.50617246986041,
    'longitude' : 11.540280981000084,
    'timestamp' : '2024-06-27T13:09:34Z'
  },
  {
    'longitude' : 11.540322705935404,
    'latitude' : 46.50735248060419,
    'altitude' : 1467.548261498101,
    'timestamp' : '2024-06-27T13:12:05Z'
  },
  {
    'timestamp' : '2024-06-27T13:12:11Z',
    'altitude' : 1466.3101081764325,
    'latitude' : 46.50741541537563,
    'longitude' : 11.540229339330608
  },
  {
    'altitude' : 1463.0085649583489,
    'timestamp' : '2024-06-27T13:12:23Z',
    'latitude' : 46.507476293873694,
    'longitude' : 11.540220150022293
  },
  {
    'timestamp' : '2024-06-27T13:12:29Z',
    'altitude' : 1462.1411541784182,
    'longitude' : 11.540169424753122,
    'latitude' : 46.507517780151026
  },
  {
    'longitude' : 11.540372483597315,
    'timestamp' : '2024-06-27T13:13:14Z',
    'altitude' : 1456.159445155412,
    'latitude' : 46.507957564322034
  },
  {
    'timestamp' : '2024-06-27T13:13:20Z',
    'latitude' : 46.508005302589915,
    'longitude' : 11.540443185601788,
    'altitude' : 1455.2068254975602
  },
  {
    'altitude' : 1452.9232979351655,
    'latitude' : 46.5081286979056,
    'timestamp' : '2024-06-27T13:13:39Z',
    'longitude' : 11.54044193316557
  },
  {
    'longitude' : 11.540445830627105,
    'timestamp' : '2024-06-27T13:13:45Z',
    'altitude' : 1448.6253849072382,
    'latitude' : 46.50822841542013
  },
  {
    'latitude' : 46.50828938709217,
    'longitude' : 11.54043701280647,
    'timestamp' : '2024-06-27T13:13:54Z',
    'altitude' : 1448.228211523965
  },
  {
    'altitude' : 1448.0038450881839,
    'latitude' : 46.50832505170501,
    'longitude' : 11.540397028731096,
    'timestamp' : '2024-06-27T13:13:59Z'
  },
  {
    'altitude' : 1446.204612643458,
    'timestamp' : '2024-06-27T13:14:05Z',
    'latitude' : 46.50837535592562,
    'longitude' : 11.54037305663465
  },
  {
    'longitude' : 11.54034061543773,
    'altitude' : 1443.0167435305193,
    'timestamp' : '2024-06-27T13:14:11Z',
    'latitude' : 46.50843567800506
  },
  {
    'altitude' : 1441.7292197318748,
    'latitude' : 46.50849241542723,
    'timestamp' : '2024-06-27T13:14:18Z',
    'longitude' : 11.540333266678456
  },
  {
    'latitude' : 46.50853749666838,
    'timestamp' : '2024-06-27T13:14:24Z',
    'longitude' : 11.54031625228061,
    'altitude' : 1442.3565128995106
  },
  {
    'latitude' : 46.5085976122962,
    'longitude' : 11.540286388254664,
    'timestamp' : '2024-06-27T13:14:35Z',
    'altitude' : 1442.4438059581444
  },
  {
    'altitude' : 1440.0167122595012,
    'latitude' : 46.50865344991313,
    'longitude' : 11.540270176664507,
    'timestamp' : '2024-06-27T13:14:43Z'
  },
  {
    'latitude' : 46.50869997032206,
    'longitude' : 11.54024797076199,
    'altitude' : 1438.7563551506028,
    'timestamp' : '2024-06-27T13:14:49Z'
  },
  {
    'timestamp' : '2024-06-27T13:14:56Z',
    'altitude' : 1437.1616471344605,
    'latitude' : 46.508753725972845,
    'longitude' : 11.540271505182606
  },
  {
    'latitude' : 46.5087987885001,
    'timestamp' : '2024-06-27T13:15:05Z',
    'longitude' : 11.54025205361039,
    'altitude' : 1435.5176054760814
  },
  {
    'altitude' : 1435.1131000583991,
    'longitude' : 11.540237785656501,
    'latitude' : 46.508848970209215,
    'timestamp' : '2024-06-27T13:15:11Z'
  },
  {
    'altitude' : 1435.9426836604252,
    'latitude' : 46.50889889069319,
    'longitude' : 11.540255689522162,
    'timestamp' : '2024-06-27T13:15:20Z'
  },
  {
    'altitude' : 1432.7703746352345,
    'latitude' : 46.508954237932286,
    'longitude' : 11.540213413658298,
    'timestamp' : '2024-06-27T13:15:28Z'
  },
  {
    'altitude' : 1431.5101827969775,
    'longitude' : 11.540184987040462,
    'timestamp' : '2024-06-27T13:15:39Z',
    'latitude' : 46.50900157898127
  },
  {
    'longitude' : 11.540221886953974,
    'altitude' : 1431.5919002173468,
    'timestamp' : '2024-06-27T13:15:45Z',
    'latitude' : 46.50905718870083
  },
  {
    'timestamp' : '2024-06-27T13:15:53Z',
    'altitude' : 1429.9531786683947,
    'longitude' : 11.540204743303004,
    'latitude' : 46.509110796414625
  },
  {
    'altitude' : 1427.5148709379137,
    'latitude' : 46.50914169237331,
    'longitude' : 11.540261945081527,
    'timestamp' : '2024-06-27T13:15:59Z'
  },
  {
    'altitude' : 1424.7390970233828,
    'latitude' : 46.50916423623877,
    'longitude' : 11.540198227340953,
    'timestamp' : '2024-06-27T13:16:05Z'
  },
  {
    'latitude' : 46.5092365926112,
    'altitude' : 1425.430341200903,
    'longitude' : 11.540188560499258,
    'timestamp' : '2024-06-27T13:16:10Z'
  },
  {
    'latitude' : 46.50928688208074,
    'longitude' : 11.54019353760512,
    'timestamp' : '2024-06-27T13:16:20Z',
    'altitude' : 1423.6424347050488
  },
  {
    'latitude' : 46.50934514343691,
    'altitude' : 1422.7101972317323,
    'timestamp' : '2024-06-27T13:16:26Z',
    'longitude' : 11.540196597934301
  },
  {
    'latitude' : 46.50939504795039,
    'timestamp' : '2024-06-27T13:16:32Z',
    'altitude' : 1421.133081088774,
    'longitude' : 11.540240345413247
  },
  {
    'altitude' : 1419.0270670978352,
    'latitude' : 46.509441840826426,
    'timestamp' : '2024-06-27T13:16:38Z',
    'longitude' : 11.540181771635915
  },
  {
    'timestamp' : '2024-06-27T13:16:45Z',
    'altitude' : 1420.6676460029557,
    'longitude' : 11.540245619469621,
    'latitude' : 46.50946934793664
  },
  {
    'latitude' : 46.50951983339762,
    'timestamp' : '2024-06-27T13:16:54Z',
    'altitude' : 1419.112322408706,
    'longitude' : 11.540214713255711
  },
  {
    'longitude' : 11.540250521345701,
    'timestamp' : '2024-06-27T13:17:02Z',
    'altitude' : 1419.3645232915878,
    'latitude' : 46.509559695523826
  },
  {
    'timestamp' : '2024-06-27T13:17:08Z',
    'altitude' : 1419.7007259121165,
    'latitude' : 46.5096405241523,
    'longitude' : 11.5403260879773
  },
  {
    'longitude' : 11.540344867364563,
    'altitude' : 1422.9168847054243,
    'latitude' : 46.509715652749655,
    'timestamp' : '2024-06-27T13:17:14Z'
  },
  {
    'latitude' : 46.50976139645677,
    'timestamp' : '2024-06-27T13:17:26Z',
    'altitude' : 1422.9733989052474,
    'longitude' : 11.540337674484448
  },
  {
    'altitude' : 1421.2369948914275,
    'longitude' : 11.540363790353204,
    'timestamp' : '2024-06-27T13:17:32Z',
    'latitude' : 46.50985479294445
  },
  {
    'altitude' : 1419.9690535878763,
    'timestamp' : '2024-06-27T13:17:38Z',
    'longitude' : 11.540439035577283,
    'latitude' : 46.509893892122776
  },
  {
    'latitude' : 46.50993121898612,
    'longitude' : 11.54052783266235,
    'altitude' : 1420.2120935572311,
    'timestamp' : '2024-06-27T13:17:44Z'
  },
  {
    'timestamp' : '2024-06-27T13:17:50Z',
    'latitude' : 46.51001602901153,
    'longitude' : 11.540559629063203,
    'altitude' : 1419.9398237941787
  },
  {
    'latitude' : 46.510062517748885,
    'timestamp' : '2024-06-27T13:17:56Z',
    'altitude' : 1418.843695761636,
    'longitude' : 11.540558756626623
  },
  {
    'longitude' : 11.540567225047273,
    'timestamp' : '2024-06-27T13:18:02Z',
    'latitude' : 46.51012224730936,
    'altitude' : 1419.6482169292867
  },
  {
    'timestamp' : '2024-06-27T13:18:08Z',
    'longitude' : 11.540597487639136,
    'latitude' : 46.51016944034171,
    'altitude' : 1419.4636984867975
  },
  {
    'timestamp' : '2024-06-27T13:18:14Z',
    'latitude' : 46.51028065201462,
    'altitude' : 1413.1264942772686,
    'longitude' : 11.540551532169085
  },
  {
    'longitude' : 11.540624805118188,
    'latitude' : 46.5103081731335,
    'altitude' : 1411.104953410104,
    'timestamp' : '2024-06-27T13:18:23Z'
  },
  {
    'timestamp' : '2024-06-27T13:18:29Z',
    'latitude' : 46.510403007215146,
    'altitude' : 1411.928045953624,
    'longitude' : 11.540621930312172
  },
  {
    'longitude' : 11.540713284241258,
    'timestamp' : '2024-06-27T13:18:35Z',
    'latitude' : 46.51043784478227,
    'altitude' : 1412.2686881991103
  },
  {
    'altitude' : 1412.5420895293355,
    'timestamp' : '2024-06-27T13:18:41Z',
    'longitude' : 11.54079315460832,
    'latitude' : 46.51045726018264
  },
  {
    'altitude' : 1415.3796991845593,
    'timestamp' : '2024-06-27T13:18:48Z',
    'longitude' : 11.54081968231861,
    'latitude' : 46.5105059921563
  },
  {
    'latitude' : 46.51057768583458,
    'longitude' : 11.540903822206346,
    'timestamp' : '2024-06-27T13:18:54Z',
    'altitude' : 1415.5069702491164
  },
  {
    'timestamp' : '2024-06-27T13:19:00Z',
    'latitude' : 46.510656466820805,
    'altitude' : 1416.1884559439495,
    'longitude' : 11.540929234699416
  },
  {
    'altitude' : 1414.5097185401246,
    'latitude' : 46.5106966578806,
    'longitude' : 11.540965518001931,
    'timestamp' : '2024-06-27T13:19:06Z'
  },
  {
    'altitude' : 1414.3027216950431,
    'latitude' : 46.51074325582484,
    'longitude' : 11.541029291153876,
    'timestamp' : '2024-06-27T13:19:12Z'
  },
  {
    'latitude' : 46.51079410039476,
    'altitude' : 1412.9342914754525,
    'longitude' : 11.541047281469643,
    'timestamp' : '2024-06-27T13:19:19Z'
  },
  {
    'longitude' : 11.54106917351582,
    'latitude' : 46.51084096025751,
    'timestamp' : '2024-06-27T13:19:25Z',
    'altitude' : 1411.3438260927796
  },
  {
    'altitude' : 1412.367150056176,
    'timestamp' : '2024-06-27T13:19:31Z',
    'longitude' : 11.541119683296976,
    'latitude' : 46.5108953722363
  },
  {
    'altitude' : 1410.5198719277978,
    'latitude' : 46.510962022660635,
    'timestamp' : '2024-06-27T13:19:37Z',
    'longitude' : 11.541177738589262
  },
  {
    'latitude' : 46.51101711324735,
    'altitude' : 1410.3036534460261,
    'timestamp' : '2024-06-27T13:19:45Z',
    'longitude' : 11.541218096415976
  },
  {
    'latitude' : 46.51106721526406,
    'longitude' : 11.541245170128237,
    'altitude' : 1409.89208604116,
    'timestamp' : '2024-06-27T13:19:51Z'
  },
  {
    'timestamp' : '2024-06-27T13:19:57Z',
    'latitude' : 46.51113120844044,
    'longitude' : 11.541291104124547,
    'altitude' : 1408.9147445997223
  },
  {
    'longitude' : 11.541319051831708,
    'altitude' : 1408.802913237363,
    'latitude' : 46.51118235149679,
    'timestamp' : '2024-06-27T13:20:04Z'
  },
  {
    'altitude' : 1408.1592695293948,
    'timestamp' : '2024-06-27T13:20:10Z',
    'latitude' : 46.51123887631501,
    'longitude' : 11.54132013206914
  },
  {
    'altitude' : 1408.2278923848644,
    'timestamp' : '2024-06-27T13:20:18Z',
    'latitude' : 46.51126270165565,
    'longitude' : 11.541385834826679
  },
  {
    'altitude' : 1406.2527309507132,
    'longitude' : 11.541395452072805,
    'timestamp' : '2024-06-27T13:20:23Z',
    'latitude' : 46.51135342488353
  },
  {
    'longitude' : 11.54142278252634,
    'timestamp' : '2024-06-27T13:20:29Z',
    'altitude' : 1404.418495257385,
    'latitude' : 46.51141476678076
  },
  {
    'latitude' : 46.51149864547926,
    'longitude' : 11.54141306877719,
    'timestamp' : '2024-06-27T13:20:35Z',
    'altitude' : 1402.412344983779
  },
  {
    'latitude' : 46.51160195553662,
    'altitude' : 1400.4044657396153,
    'longitude' : 11.541459366767606,
    'timestamp' : '2024-06-27T13:20:43Z'
  },
  {
    'latitude' : 46.51165706089894,
    'longitude' : 11.541492680000003,
    'timestamp' : '2024-06-27T13:20:51Z',
    'altitude' : 1399.6448957873508
  },
  {
    'longitude' : 11.541512459272354,
    'latitude' : 46.51171874656201,
    'altitude' : 1399.181138840504,
    'timestamp' : '2024-06-27T13:20:58Z'
  },
  {
    'latitude' : 46.511778339992425,
    'longitude' : 11.541556755022414,
    'altitude' : 1398.3357782177627,
    'timestamp' : '2024-06-27T13:21:05Z'
  },
  {
    'longitude' : 11.54156037913527,
    'timestamp' : '2024-06-27T13:21:11Z',
    'latitude' : 46.511838916356496,
    'altitude' : 1398.6542449630797
  },
  {
    'longitude' : 11.541625010722846,
    'timestamp' : '2024-06-27T13:21:17Z',
    'latitude' : 46.511905830033896,
    'altitude' : 1396.5974382059649
  },
  {
    'latitude' : 46.51195250234958,
    'longitude' : 11.541625512814258,
    'altitude' : 1395.6634257100523,
    'timestamp' : '2024-06-27T13:21:23Z'
  },
  {
    'longitude' : 11.541676566033813,
    'timestamp' : '2024-06-27T13:22:05Z',
    'altitude' : 1398.0553872995079,
    'latitude' : 46.512200613868
  },
  {
    'longitude' : 11.541661519760249,
    'timestamp' : '2024-06-27T13:22:11Z',
    'latitude' : 46.51212870667199,
    'altitude' : 1398.1523905862123
  },
  {
    'altitude' : 1400.0802901126444,
    'latitude' : 46.51211059746051,
    'timestamp' : '2024-06-27T13:22:20Z',
    'longitude' : 11.54172311438963
  },
  {
    'timestamp' : '2024-06-27T13:22:42Z',
    'latitude' : 46.51212469264213,
    'altitude' : 1399.9660977097228,
    'longitude' : 11.541653820673577
  },
  {
    'longitude' : 11.541694112548992,
    'timestamp' : '2024-06-27T13:23:12Z',
    'latitude' : 46.51206883919575,
    'altitude' : 1398.4363761013374
  },
  {
    'timestamp' : '2024-06-27T13:23:19Z',
    'altitude' : 1396.2930889492854,
    'latitude' : 46.51206635017446,
    'longitude' : 11.541773302494008
  },
  {
    'altitude' : 1395.6052175872028,
    'timestamp' : '2024-06-27T13:23:28Z',
    'longitude' : 11.541769893881296,
    'latitude' : 46.512113366096166
  },
  {
    'latitude' : 46.51220875685773,
    'longitude' : 11.541780665887797,
    'timestamp' : '2024-06-27T13:23:34Z',
    'altitude' : 1397.1877635875717
  },
  {
    'latitude' : 46.51225882350948,
    'longitude' : 11.541794574406918,
    'timestamp' : '2024-06-27T13:23:40Z',
    'altitude' : 1397.793364890851
  },
  {
    'longitude' : 11.541839737880306,
    'altitude' : 1397.8847010312602,
    'timestamp' : '2024-06-27T13:23:46Z',
    'latitude' : 46.51231663562457
  },
  {
    'longitude' : 11.541929751467128,
    'timestamp' : '2024-06-27T13:23:52Z',
    'altitude' : 1398.418656617403,
    'latitude' : 46.512350401924024
  },
  {
    'altitude' : 1397.3743249541149,
    'longitude' : 11.542007675245976,
    'timestamp' : '2024-06-27T13:23:58Z',
    'latitude' : 46.512390651500134
  },
  {
    'latitude' : 46.51240420955687,
    'altitude' : 1396.4876942923293,
    'longitude' : 11.54210136697844,
    'timestamp' : '2024-06-27T13:24:04Z'
  },
  {
    'longitude' : 11.542181816844161,
    'altitude' : 1394.7590248836204,
    'latitude' : 46.51243098749639,
    'timestamp' : '2024-06-27T13:24:10Z'
  },
  {
    'timestamp' : '2024-06-27T13:24:15Z',
    'altitude' : 1392.485203275457,
    'longitude' : 11.542241335878169,
    'latitude' : 46.51245579894308
  },
  {
    'altitude' : 1392.8759327428415,
    'timestamp' : '2024-06-27T13:24:20Z',
    'longitude' : 11.542315138947748,
    'latitude' : 46.512472705576705
  },
  {
    'altitude' : 1392.7332036886364,
    'latitude' : 46.51249376948681,
    'longitude' : 11.542373646161442,
    'timestamp' : '2024-06-27T13:24:27Z'
  },
  {
    'timestamp' : '2024-06-27T13:24:33Z',
    'latitude' : 46.51245530505212,
    'longitude' : 11.542456189747325,
    'altitude' : 1391.8109697112814
  },
  {
    'timestamp' : '2024-06-27T13:24:39Z',
    'altitude' : 1392.956914869137,
    'longitude' : 11.542543256382269,
    'latitude' : 46.5124870734333
  },
  {
    'timestamp' : '2024-06-27T13:24:45Z',
    'longitude' : 11.542634295397393,
    'altitude' : 1391.2238268945366,
    'latitude' : 46.51255130901463
  },
  {
    'latitude' : 46.51256063374598,
    'timestamp' : '2024-06-27T13:24:51Z',
    'longitude' : 11.542717155395607,
    'altitude' : 1391.0120379636064
  },
  {
    'longitude' : 11.542783648711747,
    'altitude' : 1390.6954013872892,
    'timestamp' : '2024-06-27T13:24:58Z',
    'latitude' : 46.51259931296527
  },
  {
    'altitude' : 1388.7754690563306,
    'timestamp' : '2024-06-27T13:25:05Z',
    'latitude' : 46.512613246243575,
    'longitude' : 11.54287653380806
  },
  {
    'longitude' : 11.54302322520578,
    'altitude' : 1387.0075219990686,
    'timestamp' : '2024-06-27T13:25:11Z',
    'latitude' : 46.51267926935535
  },
  {
    'longitude' : 11.543111899340753,
    'latitude' : 46.512727827790165,
    'timestamp' : '2024-06-27T13:25:17Z',
    'altitude' : 1385.8814463457093
  },
  {
    'timestamp' : '2024-06-27T13:25:23Z',
    'altitude' : 1385.2759521808475,
    'latitude' : 46.512840149720894,
    'longitude' : 11.543203246977221
  },
  {
    'altitude' : 1386.3871147399768,
    'latitude' : 46.51283624895931,
    'timestamp' : '2024-06-27T13:25:33Z',
    'longitude' : 11.543272228728437
  },
  {
    'longitude' : 11.543387636164784,
    'altitude' : 1386.4872704297304,
    'latitude' : 46.51292431249755,
    'timestamp' : '2024-06-27T13:25:39Z'
  },
  {
    'latitude' : 46.512979945076765,
    'longitude' : 11.543390563677066,
    'altitude' : 1384.753465499729,
    'timestamp' : '2024-06-27T13:25:50Z'
  },
  {
    'altitude' : 1384.8105663117021,
    'longitude' : 11.54340000713047,
    'latitude' : 46.51306812776175,
    'timestamp' : '2024-06-27T13:25:56Z'
  },
  {
    'timestamp' : '2024-06-27T13:26:03Z',
    'altitude' : 1382.121071585454,
    'longitude' : 11.543414709782882,
    'latitude' : 46.51312493610235
  },
  {
    'altitude' : 1382.4273783583194,
    'latitude' : 46.51317964223165,
    'longitude' : 11.543484632467662,
    'timestamp' : '2024-06-27T13:26:09Z'
  },
  {
    'altitude' : 1381.9539307598025,
    'latitude' : 46.51322743346082,
    'longitude' : 11.54350367492336,
    'timestamp' : '2024-06-27T13:26:17Z'
  },
  {
    'altitude' : 1382.0067589972168,
    'longitude' : 11.543557124515877,
    'timestamp' : '2024-06-27T13:26:24Z',
    'latitude' : 46.513263813317586
  },
  {
    'altitude' : 1381.8713007718325,
    'longitude' : 11.543590402560486,
    'timestamp' : '2024-06-27T13:26:29Z',
    'latitude' : 46.513342100533535
  },
  {
    'timestamp' : '2024-06-27T13:26:34Z',
    'latitude' : 46.51337284874989,
    'longitude' : 11.543656908876379,
    'altitude' : 1380.274493707344
  },
  {
    'longitude' : 11.543693479354863,
    'timestamp' : '2024-06-27T13:26:42Z',
    'altitude' : 1378.9051656331867,
    'latitude' : 46.51342599233095
  },
  {
    'latitude' : 46.51351575931654,
    'altitude' : 1376.0420390302315,
    'longitude' : 11.54377165647739,
    'timestamp' : '2024-06-27T13:26:48Z'
  },
  {
    'longitude' : 11.543837627468882,
    'altitude' : 1373.8427966628224,
    'latitude' : 46.51356492742128,
    'timestamp' : '2024-06-27T13:26:54Z'
  },
  {
    'timestamp' : '2024-06-27T13:27:02Z',
    'latitude' : 46.51360140557931,
    'longitude' : 11.54377774044954,
    'altitude' : 1372.096656982787
  },
  {
    'longitude' : 11.543766553617244,
    'altitude' : 1370.0816938206553,
    'timestamp' : '2024-06-27T13:27:08Z',
    'latitude' : 46.51365003460915
  },
  {
    'longitude' : 11.543751850551939,
    'timestamp' : '2024-06-27T13:27:14Z',
    'latitude' : 46.513709461281465,
    'altitude' : 1368.725070565939
  },
  {
    'altitude' : 1366.9316991027445,
    'latitude' : 46.51377716696073,
    'timestamp' : '2024-06-27T13:27:20Z',
    'longitude' : 11.54371924400634
  },
  {
    'longitude' : 11.543685208054901,
    'timestamp' : '2024-06-27T13:27:26Z',
    'altitude' : 1366.4085378851742,
    'latitude' : 46.51384747428505
  },
  {
    'timestamp' : '2024-06-27T13:27:34Z',
    'longitude' : 11.543619967100765,
    'altitude' : 1364.4122295444831,
    'latitude' : 46.513866025748854
  },
  {
    'latitude' : 46.513921288754304,
    'altitude' : 1363.0733394408599,
    'timestamp' : '2024-06-27T13:27:42Z',
    'longitude' : 11.543618353627801
  },
  {
    'altitude' : 1363.4476026259363,
    'timestamp' : '2024-06-27T13:27:48Z',
    'longitude' : 11.543541886095264,
    'latitude' : 46.513953393324954
  },
  {
    'latitude' : 46.5139566143521,
    'altitude' : 1367.0812052134424,
    'timestamp' : '2024-06-27T13:27:54Z',
    'longitude' : 11.543465195564606
  },
  {
    'latitude' : 46.51395517925554,
    'timestamp' : '2024-06-27T13:28:00Z',
    'altitude' : 1368.1840840214863,
    'longitude' : 11.543313393213488
  },
  {
    'altitude' : 1368.4899999629706,
    'latitude' : 46.51397914520683,
    'longitude' : 11.543255984902617,
    'timestamp' : '2024-06-27T13:28:08Z'
  },
  {
    'longitude' : 11.543218102532162,
    'altitude' : 1369.7906357664615,
    'timestamp' : '2024-06-27T13:28:14Z',
    'latitude' : 46.51401614216438
  },
  {
    'latitude' : 46.51404308318393,
    'longitude' : 11.543119500635374,
    'timestamp' : '2024-06-27T13:28:20Z',
    'altitude' : 1367.504793244414
  },
  {
    'timestamp' : '2024-06-27T13:28:29Z',
    'altitude' : 1368.8921282384545,
    'longitude' : 11.543033041828773,
    'latitude' : 46.51402477044429
  },
  {
    'timestamp' : '2024-06-27T13:28:35Z',
    'latitude' : 46.51401204052725,
    'altitude' : 1365.3406926058233,
    'longitude' : 11.542967290525427
  },
  {
    'longitude' : 11.542902587238144,
    'timestamp' : '2024-06-27T13:28:45Z',
    'latitude' : 46.5140234865763,
    'altitude' : 1365.5220331922174
  },
  {
    'timestamp' : '2024-06-27T13:28:55Z',
    'altitude' : 1362.1862906310707,
    'longitude' : 11.54286900171159,
    'latitude' : 46.51406294940617
  },
  {
    'timestamp' : '2024-06-27T13:29:01Z',
    'latitude' : 46.514098786478606,
    'longitude' : 11.54282031629467,
    'altitude' : 1360.9748161276802
  },
  {
    'altitude' : 1356.1247843997553,
    'longitude' : 11.542715036978745,
    'timestamp' : '2024-06-27T13:29:07Z',
    'latitude' : 46.51421646184198
  },
  {
    'timestamp' : '2024-06-27T13:29:18Z',
    'latitude' : 46.514258704429906,
    'longitude' : 11.542649854969103,
    'altitude' : 1354.262406799011
  },
  {
    'altitude' : 1355.1361742373556,
    'longitude' : 11.542602838045962,
    'timestamp' : '2024-06-27T13:29:34Z',
    'latitude' : 46.51429190312782
  },
  {
    'timestamp' : '2024-06-27T13:29:40Z',
    'latitude' : 46.51433730695967,
    'altitude' : 1357.6720615960658,
    'longitude' : 11.542559099114957
  },
  {
    'longitude' : 11.542465631925692,
    'altitude' : 1356.3466706294566,
    'timestamp' : '2024-06-27T13:29:46Z',
    'latitude' : 46.51436153172611
  },
  {
    'longitude' : 11.5423741471882,
    'timestamp' : '2024-06-27T13:29:52Z',
    'altitude' : 1353.096390902996,
    'latitude' : 46.51439653899509
  },
  {
    'latitude' : 46.51443748900012,
    'longitude' : 11.542309808946861,
    'altitude' : 1349.8625752171502,
    'timestamp' : '2024-06-27T13:29:58Z'
  },
  {
    'latitude' : 46.51442275226894,
    'altitude' : 1350.6723259901628,
    'longitude' : 11.542175696764378,
    'timestamp' : '2024-06-27T13:30:04Z'
  },
  {
    'altitude' : 1345.631631319411,
    'timestamp' : '2024-06-27T13:30:10Z',
    'longitude' : 11.542092690030062,
    'latitude' : 46.514462046237085
  },
  {
    'altitude' : 1345.8467037156224,
    'latitude' : 46.51450092077225,
    'longitude' : 11.542031541610443,
    'timestamp' : '2024-06-27T13:30:16Z'
  },
  {
    'altitude' : 1344.3401193264872,
    'timestamp' : '2024-06-27T13:30:24Z',
    'latitude' : 46.514461819475365,
    'longitude' : 11.54191460385179
  },
  {
    'altitude' : 1344.7470859223977,
    'latitude' : 46.51450840692715,
    'longitude' : 11.54186688378865,
    'timestamp' : '2024-06-27T13:30:35Z'
  },
  {
    'latitude' : 46.51454962313672,
    'longitude' : 11.541826954754987,
    'timestamp' : '2024-06-27T13:30:43Z',
    'altitude' : 1344.0430128863081
  },
  {
    'altitude' : 1345.0512732677162,
    'longitude' : 11.54180174124379,
    'timestamp' : '2024-06-27T13:30:53Z',
    'latitude' : 46.514506688280456
  },
  {
    'timestamp' : '2024-06-27T13:31:10Z',
    'altitude' : 1341.0200497303158,
    'latitude' : 46.51446820883214,
    'longitude' : 11.541836928737434
  },
  {
    'altitude' : 1339.1678892541677,
    'timestamp' : '2024-06-27T13:31:17Z',
    'longitude' : 11.541771529783663,
    'latitude' : 46.51446738365725
  },
  {
    'timestamp' : '2024-06-27T13:31:28Z',
    'altitude' : 1341.0155476806685,
    'longitude' : 11.541698734694457,
    'latitude' : 46.51449391682828
  },
  {
    'altitude' : 1343.8637227499858,
    'latitude' : 46.51454199885083,
    'timestamp' : '2024-06-27T13:31:40Z',
    'longitude' : 11.541660326871318
  },
  {
    'latitude' : 46.51459263929938,
    'altitude' : 1343.0887381732464,
    'longitude' : 11.541644087296408,
    'timestamp' : '2024-06-27T13:31:46Z'
  },
  {
    'longitude' : 11.541564974452221,
    'altitude' : 1340.5888692913577,
    'timestamp' : '2024-06-27T13:31:52Z',
    'latitude' : 46.51465631067783
  },
  {
    'longitude' : 11.541524472163236,
    'altitude' : 1341.0520652867854,
    'timestamp' : '2024-06-27T13:31:59Z',
    'latitude' : 46.5146953785327
  },
  {
    'altitude' : 1340.235566121526,
    'latitude' : 46.51473529006851,
    'timestamp' : '2024-06-27T13:32:05Z',
    'longitude' : 11.541419956893812
  },
  {
    'latitude' : 46.51480704960824,
    'altitude' : 1337.5886419499293,
    'timestamp' : '2024-06-27T13:32:11Z',
    'longitude' : 11.541321000401071
  },
  {
    'timestamp' : '2024-06-27T13:32:17Z',
    'longitude' : 11.541242118232294,
    'latitude' : 46.514843336497066,
    'altitude' : 1336.1026006042957
  },
  {
    'altitude' : 1332.5024084197357,
    'longitude' : 11.541159052906261,
    'timestamp' : '2024-06-27T13:32:23Z',
    'latitude' : 46.5148969225924
  },
  {
    'latitude' : 46.51489708596375,
    'longitude' : 11.541084252246321,
    'altitude' : 1333.6265359213576,
    'timestamp' : '2024-06-27T13:32:30Z'
  },
  {
    'timestamp' : '2024-06-27T13:32:40Z',
    'latitude' : 46.51486704805054,
    'altitude' : 1337.778442482464,
    'longitude' : 11.541016326789485
  },
  {
    'altitude' : 1337.3634854778647,
    'timestamp' : '2024-06-27T13:32:45Z',
    'latitude' : 46.51484555927657,
    'longitude' : 11.540941782852611
  },
  {
    'altitude' : 1334.291515218094,
    'timestamp' : '2024-06-27T13:32:52Z',
    'latitude' : 46.514856044456046,
    'longitude' : 11.540873353577606
  },
  {
    'altitude' : 1334.9912125645205,
    'longitude' : 11.540805762589297,
    'latitude' : 46.51488327474536,
    'timestamp' : '2024-06-27T13:32:58Z'
  },
  {
    'latitude' : 46.514951864756554,
    'altitude' : 1331.0771616687998,
    'longitude' : 11.540703590007269,
    'timestamp' : '2024-06-27T13:33:04Z'
  },
  {
    'altitude' : 1331.7261244123802,
    'timestamp' : '2024-06-27T13:33:10Z',
    'longitude' : 11.54063853866984,
    'latitude' : 46.5149746016721
  },
  {
    'altitude' : 1326.4397505111992,
    'timestamp' : '2024-06-27T13:33:16Z',
    'longitude' : 11.540553382589714,
    'latitude' : 46.51500891602274
  },
  {
    'longitude' : 11.5404926685221,
    'altitude' : 1325.3441012091935,
    'latitude' : 46.514989394533565,
    'timestamp' : '2024-06-27T13:33:22Z'
  },
  {
    'latitude' : 46.51500729546248,
    'altitude' : 1324.9245891803876,
    'longitude' : 11.540432264654664,
    'timestamp' : '2024-06-27T13:33:28Z'
  },
  {
    'latitude' : 46.51502875873684,
    'altitude' : 1322.8912754198536,
    'timestamp' : '2024-06-27T13:33:34Z',
    'longitude' : 11.540369865455993
  },
  {
    'longitude' : 11.540311347726364,
    'timestamp' : '2024-06-27T13:33:43Z',
    'altitude' : 1320.7775868000463,
    'latitude' : 46.515054342110666
  },
  {
    'latitude' : 46.515069306333395,
    'altitude' : 1319.90965428669,
    'longitude' : 11.54024264992724,
    'timestamp' : '2024-06-27T13:33:50Z'
  },
  {
    'longitude' : 11.540191021250317,
    'latitude' : 46.51511294914708,
    'altitude' : 1318.3776619108394,
    'timestamp' : '2024-06-27T13:33:56Z'
  },
  {
    'timestamp' : '2024-06-27T13:34:02Z',
    'altitude' : 1316.7176838768646,
    'longitude' : 11.540106915698995,
    'latitude' : 46.51513952315664
  },
  {
    'latitude' : 46.51515790218563,
    'altitude' : 1315.5439676167443,
    'longitude' : 11.540041866266929,
    'timestamp' : '2024-06-27T13:34:08Z'
  },
  {
    'timestamp' : '2024-06-27T13:34:15Z',
    'latitude' : 46.51519302865553,
    'longitude' : 11.53999109502384,
    'altitude' : 1314.9327827617526
  },
  {
    'altitude' : 1313.5867225639522,
    'latitude' : 46.5152210981348,
    'timestamp' : '2024-06-27T13:34:21Z',
    'longitude' : 11.539925813761567
  },
  {
    'longitude' : 11.539870536060715,
    'timestamp' : '2024-06-27T13:34:27Z',
    'latitude' : 46.51525503793749,
    'altitude' : 1309.7703920239583
  },
  {
    'latitude' : 46.515285986540896,
    'timestamp' : '2024-06-27T13:34:34Z',
    'longitude' : 11.539809973269161,
    'altitude' : 1309.794466146268
  },
  {
    'timestamp' : '2024-06-27T13:34:40Z',
    'latitude' : 46.515319318411585,
    'altitude' : 1308.5330931544304,
    'longitude' : 11.539741201160924
  },
  {
    'longitude' : 11.539685888802973,
    'timestamp' : '2024-06-27T13:34:48Z',
    'altitude' : 1308.7671269159764,
    'latitude' : 46.51535605978682
  },
  {
    'longitude' : 11.53961054745122,
    'latitude' : 46.51537795062948,
    'timestamp' : '2024-06-27T13:34:54Z',
    'altitude' : 1306.6831163829193
  },
  {
    'altitude' : 1307.076131732203,
    'longitude' : 11.539559324947032,
    'latitude' : 46.51541300531695,
    'timestamp' : '2024-06-27T13:34:59Z'
  },
  {
    'altitude' : 1304.3561187768355,
    'latitude' : 46.51546255885085,
    'longitude' : 11.53947101991231,
    'timestamp' : '2024-06-27T13:35:05Z'
  },
  {
    'altitude' : 1304.5186067447066,
    'latitude' : 46.515487186456475,
    'longitude' : 11.539408825206277,
    'timestamp' : '2024-06-27T13:35:11Z'
  },
  {
    'latitude' : 46.51552951250156,
    'altitude' : 1304.1643689321354,
    'longitude' : 11.53934471380229,
    'timestamp' : '2024-06-27T13:35:17Z'
  },
  {
    'altitude' : 1303.5009403117,
    'latitude' : 46.515555371762524,
    'longitude' : 11.539247216251965,
    'timestamp' : '2024-06-27T13:35:23Z'
  },
  {
    'altitude' : 1304.4007831951603,
    'latitude' : 46.51559485294374,
    'longitude' : 11.539177715125339,
    'timestamp' : '2024-06-27T13:35:29Z'
  },
  {
    'timestamp' : '2024-06-27T13:35:36Z',
    'altitude' : 1306.653142134659,
    'latitude' : 46.51562674564821,
    'longitude' : 11.539127544640834
  },
  {
    'altitude' : 1306.4645077669993,
    'timestamp' : '2024-06-27T13:35:42Z',
    'latitude' : 46.51565674642336,
    'longitude' : 11.539073123736758
  },
  {
    'longitude' : 11.539017302555564,
    'latitude' : 46.51569078044619,
    'altitude' : 1305.7624103259295,
    'timestamp' : '2024-06-27T13:35:48Z'
  },
  {
    'latitude' : 46.51569983570043,
    'longitude' : 11.538917897985439,
    'timestamp' : '2024-06-27T13:35:56Z',
    'altitude' : 1303.1349646961316
  },
  {
    'timestamp' : '2024-06-27T13:36:02Z',
    'altitude' : 1300.48085441906,
    'longitude' : 11.538790090742548,
    'latitude' : 46.515730222977375
  },
  {
    'altitude' : 1298.015654974617,
    'latitude' : 46.51578033413148,
    'longitude' : 11.538732062811318,
    'timestamp' : '2024-06-27T13:36:08Z'
  },
  {
    'longitude' : 11.538663273608462,
    'latitude' : 46.51578510438036,
    'timestamp' : '2024-06-27T13:36:14Z',
    'altitude' : 1298.2083148313686
  },
  {
    'timestamp' : '2024-06-27T13:36:20Z',
    'altitude' : 1296.2103338176385,
    'longitude' : 11.5385803031192,
    'latitude' : 46.51581708769243
  },
  {
    'longitude' : 11.538518358386769,
    'timestamp' : '2024-06-27T13:36:26Z',
    'latitude' : 46.515839809583206,
    'altitude' : 1294.4488537861034
  },
  {
    'altitude' : 1292.2257207566872,
    'longitude' : 11.538407802332015,
    'timestamp' : '2024-06-27T13:36:32Z',
    'latitude' : 46.51588263988651
  },
  {
    'longitude' : 11.538327766630044,
    'altitude' : 1291.6510784942657,
    'latitude' : 46.51592450650748,
    'timestamp' : '2024-06-27T13:36:38Z'
  },
  {
    'longitude' : 11.538256678199279,
    'latitude' : 46.5159561133663,
    'timestamp' : '2024-06-27T13:36:45Z',
    'altitude' : 1291.5940747512504
  },
  {
    'altitude' : 1290.2843251526356,
    'timestamp' : '2024-06-27T13:36:51Z',
    'latitude' : 46.516014957925236,
    'longitude' : 11.538223316318748
  },
  {
    'altitude' : 1288.984098708257,
    'timestamp' : '2024-06-27T13:36:56Z',
    'latitude' : 46.51603046181883,
    'longitude' : 11.538134352495922
  },
  {
    'latitude' : 46.51606956951446,
    'longitude' : 11.538065203596634,
    'timestamp' : '2024-06-27T13:37:01Z',
    'altitude' : 1287.6588737377897
  },
  {
    'timestamp' : '2024-06-27T13:37:06Z',
    'altitude' : 1287.5746065052226,
    'latitude' : 46.516144405668,
    'longitude' : 11.537974473636961
  },
  {
    'longitude' : 11.537937603265442,
    'timestamp' : '2024-06-27T13:37:12Z',
    'latitude' : 46.516207968461735,
    'altitude' : 1288.0228471616283
  },
  {
    'longitude' : 11.537899856045819,
    'altitude' : 1288.1535682762042,
    'latitude' : 46.51624927041222,
    'timestamp' : '2024-06-27T13:37:21Z'
  },
  {
    'altitude' : 1288.1941847475246,
    'longitude' : 11.537829976402776,
    'latitude' : 46.51628116369864,
    'timestamp' : '2024-06-27T13:37:27Z'
  },
  {
    'latitude' : 46.5163084104183,
    'altitude' : 1287.8958328608423,
    'timestamp' : '2024-06-27T13:37:33Z',
    'longitude' : 11.537777566059603
  },
  {
    'timestamp' : '2024-06-27T13:37:40Z',
    'altitude' : 1285.9926903089508,
    'longitude' : 11.537742974271618,
    'latitude' : 46.51635268617622
  },
  {
    'longitude' : 11.537635158031676,
    'altitude' : 1283.9871228681877,
    'latitude' : 46.51642755735984,
    'timestamp' : '2024-06-27T13:37:46Z'
  },
  {
    'longitude' : 11.537669139265573,
    'timestamp' : '2024-06-27T13:37:54Z',
    'altitude' : 1280.5683556515723,
    'latitude' : 46.516471415469354
  },
  {
    'timestamp' : '2024-06-27T13:38:00Z',
    'latitude' : 46.51653600613397,
    'longitude' : 11.537587471951912,
    'altitude' : 1283.352173360996
  },
  {
    'timestamp' : '2024-06-27T13:38:06Z',
    'altitude' : 1281.7762317880988,
    'latitude' : 46.51659375492794,
    'longitude' : 11.537543599612514
  },
  {
    'altitude' : 1277.317954685539,
    'latitude' : 46.51667539351631,
    'longitude' : 11.537465761497785,
    'timestamp' : '2024-06-27T13:38:12Z'
  },
  {
    'altitude' : 1274.5012063244358,
    'longitude' : 11.537449512703624,
    'latitude' : 46.51673304521729,
    'timestamp' : '2024-06-27T13:38:20Z'
  },
  {
    'latitude' : 46.516800084577795,
    'longitude' : 11.537372925384023,
    'timestamp' : '2024-06-27T13:38:26Z',
    'altitude' : 1272.6167497374117
  },
  {
    'altitude' : 1272.9251628182828,
    'latitude' : 46.51685469298044,
    'longitude' : 11.537312585425353,
    'timestamp' : '2024-06-27T13:38:32Z'
  },
  {
    'timestamp' : '2024-06-27T13:38:38Z',
    'altitude' : 1269.4394878204912,
    'latitude' : 46.51693034832472,
    'longitude' : 11.537218784062908
  },
  {
    'longitude' : 11.53719368477357,
    'latitude' : 46.516984664712616,
    'timestamp' : '2024-06-27T13:38:44Z',
    'altitude' : 1272.518054652959
  },
  {
    'latitude' : 46.517040058864424,
    'altitude' : 1272.514124627225,
    'longitude' : 11.537171669924941,
    'timestamp' : '2024-06-27T13:38:50Z'
  },
  {
    'timestamp' : '2024-06-27T13:38:57Z',
    'latitude' : 46.51710210839205,
    'longitude' : 11.537054281518301,
    'altitude' : 1269.2416852843016
  },
  {
    'altitude' : 1265.9976602392271,
    'timestamp' : '2024-06-27T13:39:03Z',
    'latitude' : 46.51714873482902,
    'longitude' : 11.536963709308706
  },
  {
    'timestamp' : '2024-06-27T13:39:09Z',
    'altitude' : 1263.4076287467033,
    'latitude' : 46.51720971462257,
    'longitude' : 11.53688923806341
  },
  {
    'altitude' : 1262.9608986843377,
    'longitude' : 11.536833327110022,
    'latitude' : 46.51727407922609,
    'timestamp' : '2024-06-27T13:39:14Z'
  },
  {
    'longitude' : 11.536756109468953,
    'latitude' : 46.517345300924326,
    'timestamp' : '2024-06-27T13:39:20Z',
    'altitude' : 1261.627140475437
  },
  {
    'timestamp' : '2024-06-27T13:39:26Z',
    'longitude' : 11.536685184919243,
    'latitude' : 46.51739013226411,
    'altitude' : 1260.9078551204875
  },
  {
    'timestamp' : '2024-06-27T13:39:32Z',
    'longitude' : 11.536635071342673,
    'altitude' : 1260.940457274206,
    'latitude' : 46.51743903231833
  },
  {
    'altitude' : 1260.2100181225687,
    'latitude' : 46.51749037521812,
    'longitude' : 11.536568065335263,
    'timestamp' : '2024-06-27T13:39:38Z'
  },
  {
    'longitude' : 11.53649876320935,
    'latitude' : 46.517535555819414,
    'timestamp' : '2024-06-27T13:39:44Z',
    'altitude' : 1259.926582804881
  },
  {
    'altitude' : 1259.8355867061764,
    'latitude' : 46.51758991508641,
    'longitude' : 11.536444666425249,
    'timestamp' : '2024-06-27T13:39:50Z'
  },
  {
    'latitude' : 46.517658047031205,
    'longitude' : 11.536415386744999,
    'timestamp' : '2024-06-27T13:39:56Z',
    'altitude' : 1259.6447766963392
  },
  {
    'longitude' : 11.53636363602511,
    'timestamp' : '2024-06-27T13:40:02Z',
    'altitude' : 1260.0141157079488,
    'latitude' : 46.51771590768333
  },
  {
    'longitude' : 11.536253657692628,
    'timestamp' : '2024-06-27T13:40:08Z',
    'altitude' : 1259.4075828129426,
    'latitude' : 46.51776161042716
  },
  {
    'latitude' : 46.517790747430965,
    'altitude' : 1259.7297186274081,
    'timestamp' : '2024-06-27T13:40:14Z',
    'longitude' : 11.536147293638168
  },
  {
    'timestamp' : '2024-06-27T13:40:20Z',
    'altitude' : 1259.4029150204733,
    'latitude' : 46.517802320101985,
    'longitude' : 11.536038254068606
  },
  {
    'timestamp' : '2024-06-27T13:40:26Z',
    'altitude' : 1258.7324756840244,
    'longitude' : 11.535920461689633,
    'latitude' : 46.51780140035284
  },
  {
    'timestamp' : '2024-06-27T13:40:32Z',
    'altitude' : 1257.8182469541207,
    'latitude' : 46.5178020962353,
    'longitude' : 11.535806113917422
  },
  {
    'latitude' : 46.517761225638914,
    'longitude' : 11.535733733502738,
    'timestamp' : '2024-06-27T13:40:38Z',
    'altitude' : 1257.4487338000908
  },
  {
    'timestamp' : '2024-06-27T13:40:44Z',
    'longitude' : 11.535653827081584,
    'altitude' : 1254.9176766183227,
    'latitude' : 46.51771280288614
  },
  {
    'altitude' : 1255.1755568906665,
    'longitude' : 11.53558568261652,
    'timestamp' : '2024-06-27T13:40:50Z',
    'latitude' : 46.517670741730754
  },
  {
    'latitude' : 46.51763507440164,
    'altitude' : 1254.8706799754873,
    'longitude' : 11.535509733666096,
    'timestamp' : '2024-06-27T13:40:56Z'
  },
  {
    'timestamp' : '2024-06-27T13:41:03Z',
    'altitude' : 1255.038294150494,
    'longitude' : 11.535417817983964,
    'latitude' : 46.517607846911
  },
  {
    'timestamp' : '2024-06-27T13:41:09Z',
    'longitude' : 11.53531083685038,
    'altitude' : 1253.732967720367,
    'latitude' : 46.517576938359866
  },
  {
    'latitude' : 46.517562754639776,
    'longitude' : 11.535224430996132,
    'altitude' : 1252.8237832523882,
    'timestamp' : '2024-06-27T13:41:15Z'
  },
  {
    'timestamp' : '2024-06-27T13:41:20Z',
    'altitude' : 1251.3408574955538,
    'longitude' : 11.53513409666221,
    'latitude' : 46.51757089182416
  },
  {
    'longitude' : 11.535063980098252,
    'altitude' : 1250.5030083870515,
    'latitude' : 46.51760261395373,
    'timestamp' : '2024-06-27T13:41:27Z'
  },
  {
    'latitude' : 46.517595092256954,
    'altitude' : 1249.705085885711,
    'timestamp' : '2024-06-27T13:41:33Z',
    'longitude' : 11.534995843315137
  },
  {
    'timestamp' : '2024-06-27T13:41:39Z',
    'longitude' : 11.534914112950078,
    'altitude' : 1248.3579356782138,
    'latitude' : 46.517582026261415
  },
  {
    'latitude' : 46.51755088269032,
    'longitude' : 11.534853940306103,
    'timestamp' : '2024-06-27T13:41:46Z',
    'altitude' : 1248.2121932459995
  },
  {
    'timestamp' : '2024-06-27T13:41:52Z',
    'altitude' : 1245.8661560053006,
    'latitude' : 46.51751953953797,
    'longitude' : 11.534756878828658
  },
  {
    'altitude' : 1247.2532555079088,
    'timestamp' : '2024-06-27T13:42:01Z',
    'longitude' : 11.534727787673887,
    'latitude' : 46.5174665110459
  },
  {
    'altitude' : 1244.057330599986,
    'timestamp' : '2024-06-27T13:42:07Z',
    'latitude' : 46.51741452349367,
    'longitude' : 11.534698210907544
  },
  {
    'timestamp' : '2024-06-27T13:42:13Z',
    'longitude' : 11.534612948325922,
    'altitude' : 1243.0891144070774,
    'latitude' : 46.51737792653483
  },
  {
    'longitude' : 11.534546980908505,
    'altitude' : 1243.3480347162113,
    'timestamp' : '2024-06-27T13:42:20Z',
    'latitude' : 46.5173536338187
  },
  {
    'altitude' : 1241.6359707098454,
    'latitude' : 46.51732148670244,
    'longitude' : 11.534499653373285,
    'timestamp' : '2024-06-27T13:42:26Z'
  },
  {
    'longitude' : 11.534446337346218,
    'altitude' : 1239.4623134601861,
    'latitude' : 46.517291612215125,
    'timestamp' : '2024-06-27T13:42:32Z'
  },
  {
    'latitude' : 46.51724924682327,
    'altitude' : 1238.071884892881,
    'longitude' : 11.53440474238582,
    'timestamp' : '2024-06-27T13:42:38Z'
  },
  {
    'longitude' : 11.534391163278798,
    'timestamp' : '2024-06-27T13:42:45Z',
    'latitude' : 46.51720201786243,
    'altitude' : 1237.0255675576627
  },
  {
    'longitude' : 11.534319015204865,
    'latitude' : 46.517164461468326,
    'timestamp' : '2024-06-27T13:42:51Z',
    'altitude' : 1235.0621711146086
  },
  {
    'timestamp' : '2024-06-27T13:42:57Z',
    'longitude' : 11.534243988623254,
    'altitude' : 1231.8588858861476,
    'latitude' : 46.51712686209238
  },
  {
    'altitude' : 1231.1768830930814,
    'latitude' : 46.517086879192824,
    'longitude' : 11.534206092744325,
    'timestamp' : '2024-06-27T13:43:04Z'
  },
  {
    'altitude' : 1232.0080418735743,
    'latitude' : 46.51703619579601,
    'longitude' : 11.53415529929846,
    'timestamp' : '2024-06-27T13:43:16Z'
  },
  {
    'latitude' : 46.51698201784339,
    'longitude' : 11.53413346301188,
    'timestamp' : '2024-06-27T13:43:24Z',
    'altitude' : 1231.680094459094
  },
  {
    'altitude' : 1234.109181219712,
    'latitude' : 46.516965516660576,
    'timestamp' : '2024-06-27T13:43:30Z',
    'longitude' : 11.534054355264027
  },
  {
    'timestamp' : '2024-06-27T13:43:36Z',
    'latitude' : 46.51692858090236,
    'altitude' : 1230.7131890198216,
    'longitude' : 11.533975905030616
  },
  {
    'latitude' : 46.51692600973087,
    'longitude' : 11.53390128471237,
    'altitude' : 1227.8756444016472,
    'timestamp' : '2024-06-27T13:43:42Z'
  },
  {
    'altitude' : 1227.2896696301177,
    'latitude' : 46.51690998747659,
    'timestamp' : '2024-06-27T13:43:54Z',
    'longitude' : 11.533833646576195
  },
  {
    'longitude' : 11.533762949253106,
    'latitude' : 46.51688270934253,
    'altitude' : 1227.0264488048851,
    'timestamp' : '2024-06-27T13:44:00Z'
  },
  {
    'longitude' : 11.533677489189255,
    'timestamp' : '2024-06-27T13:44:06Z',
    'altitude' : 1226.6145186834037,
    'latitude' : 46.51688492072408
  },
  {
    'altitude' : 1225.883427247405,
    'longitude' : 11.533599711592933,
    'latitude' : 46.51689528738722,
    'timestamp' : '2024-06-27T13:44:12Z'
  },
  {
    'longitude' : 11.533532378702617,
    'altitude' : 1225.231430394575,
    'timestamp' : '2024-06-27T13:44:18Z',
    'latitude' : 46.5168831460139
  },
  {
    'longitude' : 11.533461414410144,
    'latitude' : 46.51689628129367,
    'timestamp' : '2024-06-27T13:44:27Z',
    'altitude' : 1224.2067560730502
  },
  {
    'latitude' : 46.51688699951289,
    'longitude' : 11.533330441298453,
    'timestamp' : '2024-06-27T13:44:33Z',
    'altitude' : 1219.035689287819
  },
  {
    'latitude' : 46.516878955953665,
    'timestamp' : '2024-06-27T13:44:39Z',
    'longitude' : 11.53325257581096,
    'altitude' : 1217.6040673190728
  },
  {
    'altitude' : 1216.2444867268205,
    'latitude' : 46.51688328900511,
    'timestamp' : '2024-06-27T13:44:45Z',
    'longitude' : 11.533181969861156
  },
  {
    'altitude' : 1215.9923251867294,
    'timestamp' : '2024-06-27T13:44:52Z',
    'longitude' : 11.533110660685784,
    'latitude' : 46.516883407043316
  },
  {
    'altitude' : 1216.594481694512,
    'longitude' : 11.533046587030087,
    'latitude' : 46.51689670645278,
    'timestamp' : '2024-06-27T13:44:58Z'
  },
  {
    'timestamp' : '2024-06-27T13:45:04Z',
    'longitude' : 11.532951610584892,
    'altitude' : 1219.0792742827907,
    'latitude' : 46.51691409007519
  },
  {
    'longitude' : 11.532896963672842,
    'latitude' : 46.51694648729214,
    'timestamp' : '2024-06-27T13:45:10Z',
    'altitude' : 1216.2200928917155
  },
  {
    'latitude' : 46.516974817729626,
    'longitude' : 11.532836203695206,
    'timestamp' : '2024-06-27T13:45:17Z',
    'altitude' : 1215.0924311671406
  },
  {
    'timestamp' : '2024-06-27T13:45:23Z',
    'altitude' : 1212.3903316901997,
    'latitude' : 46.516984060768706,
    'longitude' : 11.53274886521215
  },
  {
    'timestamp' : '2024-06-27T13:45:29Z',
    'latitude' : 46.5170085162701,
    'longitude' : 11.532676536619809,
    'altitude' : 1211.146200440824
  },
  {
    'longitude' : 11.53259731848783,
    'altitude' : 1208.3585405331105,
    'timestamp' : '2024-06-27T13:45:34Z',
    'latitude' : 46.517024941936164
  },
  {
    'timestamp' : '2024-06-27T13:45:40Z',
    'latitude' : 46.51703063633287,
    'longitude' : 11.532519671975118,
    'altitude' : 1208.5227422621101
  },
  {
    'longitude' : 11.532437863802942,
    'timestamp' : '2024-06-27T13:45:54Z',
    'latitude' : 46.51701861042174,
    'altitude' : 1211.7300962340087
  },
  {
    'timestamp' : '2024-06-27T13:46:04Z',
    'longitude' : 11.532363467329748,
    'altitude' : 1207.8911773087457,
    'latitude' : 46.51700168158002
  },
  {
    'altitude' : 1205.7461159443483,
    'timestamp' : '2024-06-27T13:46:12Z',
    'latitude' : 46.51702286090524,
    'longitude' : 11.532280744385488
  },
  {
    'latitude' : 46.51696716484889,
    'longitude' : 11.532256721171228,
    'altitude' : 1203.9425267679617,
    'timestamp' : '2024-06-27T13:46:18Z'
  },
  {
    'altitude' : 1201.8437130637467,
    'latitude' : 46.51694865088188,
    'timestamp' : '2024-06-27T13:46:26Z',
    'longitude' : 11.532185283785727
  },
  {
    'altitude' : 1200.7857208978385,
    'latitude' : 46.51699167883605,
    'longitude' : 11.532151323814835,
    'timestamp' : '2024-06-27T13:46:32Z'
  },
  {
    'longitude' : 11.532077183526827,
    'latitude' : 46.516975475799946,
    'altitude' : 1199.3708484238014,
    'timestamp' : '2024-06-27T13:46:41Z'
  },
  {
    'longitude' : 11.53200970605934,
    'latitude' : 46.5169546899417,
    'altitude' : 1197.0698631759733,
    'timestamp' : '2024-06-27T13:46:51Z'
  },
  {
    'longitude' : 11.531950005474311,
    'altitude' : 1195.3537228377536,
    'timestamp' : '2024-06-27T13:47:02Z',
    'latitude' : 46.51697927044452
  },
  {
    'latitude' : 46.517012738765445,
    'timestamp' : '2024-06-27T13:47:09Z',
    'longitude' : 11.531903618228485,
    'altitude' : 1192.5907278228551
  },
  {
    'longitude' : 11.531852419427393,
    'timestamp' : '2024-06-27T13:47:16Z',
    'altitude' : 1191.78296623379,
    'latitude' : 46.517046637781355
  },
  {
    'timestamp' : '2024-06-27T13:47:31Z',
    'latitude' : 46.517053716879,
    'altitude' : 1193.1181643400341,
    'longitude' : 11.531779591012148
  },
  {
    'longitude' : 11.531715395768446,
    'latitude' : 46.517076139706234,
    'timestamp' : '2024-06-27T13:47:37Z',
    'altitude' : 1192.0234924172983
  },
  {
    'timestamp' : '2024-06-27T13:47:46Z',
    'altitude' : 1190.4852686589584,
    'latitude' : 46.51711777779596,
    'longitude' : 11.531686116991846
  },
  {
    'longitude' : 11.531616825674636,
    'timestamp' : '2024-06-27T13:47:52Z',
    'altitude' : 1190.6634811619297,
    'latitude' : 46.51710745504041
  },
  {
    'altitude' : 1189.6750513333827,
    'longitude' : 11.531558160482986,
    'timestamp' : '2024-06-27T13:47:58Z',
    'latitude' : 46.51713841331353
  },
  {
    'longitude' : 11.531498877669689,
    'timestamp' : '2024-06-27T13:48:06Z',
    'altitude' : 1187.9285944346339,
    'latitude' : 46.51716289627248
  },
  {
    'latitude' : 46.51720418642786,
    'longitude' : 11.531469695982723,
    'altitude' : 1185.801048696041,
    'timestamp' : '2024-06-27T13:48:15Z'
  },
  {
    'altitude' : 1182.9744291435927,
    'timestamp' : '2024-06-27T13:48:23Z',
    'latitude' : 46.51721234143663,
    'longitude' : 11.531398436142716
  },
  {
    'latitude' : 46.5172621405986,
    'longitude' : 11.531406998582868,
    'altitude' : 1181.0565478848293,
    'timestamp' : '2024-06-27T13:48:29Z'
  },
  {
    'longitude' : 11.53136586892079,
    'latitude' : 46.517302661993874,
    'timestamp' : '2024-06-27T13:48:37Z',
    'altitude' : 1179.2032974371687
  },
  {
    'altitude' : 1179.472188479267,
    'latitude' : 46.51734934050564,
    'timestamp' : '2024-06-27T13:48:46Z',
    'longitude' : 11.531346546431775
  },
  {
    'longitude' : 11.531364418540097,
    'altitude' : 1177.9520101556554,
    'timestamp' : '2024-06-27T13:48:52Z',
    'latitude' : 46.517393628599415
  },
  {
    'latitude' : 46.51744526411722,
    'altitude' : 1176.0787282921374,
    'timestamp' : '2024-06-27T13:49:02Z',
    'longitude' : 11.531309499594085
  },
  {
    'timestamp' : '2024-06-27T13:49:08Z',
    'latitude' : 46.517516982452584,
    'longitude' : 11.531301138504153,
    'altitude' : 1173.1045407075435
  },
  {
    'altitude' : 1171.745033763349,
    'latitude' : 46.51756614502386,
    'timestamp' : '2024-06-27T13:49:16Z',
    'longitude' : 11.531289695080899
  },
  {
    'latitude' : 46.517618081352154,
    'timestamp' : '2024-06-27T13:49:22Z',
    'altitude' : 1169.4313655868173,
    'longitude' : 11.531281434326967
  },
  {
    'timestamp' : '2024-06-27T13:49:27Z',
    'altitude' : 1168.9963666917756,
    'longitude' : 11.531281481447902,
    'latitude' : 46.5176677579373
  },
  {
    'altitude' : 1167.7454985501245,
    'latitude' : 46.517739102247475,
    'longitude' : 11.531267570580138,
    'timestamp' : '2024-06-27T13:49:33Z'
  },
  {
    'altitude' : 1166.6352781765163,
    'longitude' : 11.53127856554738,
    'latitude' : 46.51778433385064,
    'timestamp' : '2024-06-27T13:49:40Z'
  },
  {
    'longitude' : 11.531330635986633,
    'latitude' : 46.51781319787498,
    'altitude' : 1167.7275062389672,
    'timestamp' : '2024-06-27T13:49:46Z'
  },
  {
    'latitude' : 46.51788571723202,
    'timestamp' : '2024-06-27T13:49:52Z',
    'longitude' : 11.531356484361607,
    'altitude' : 1169.3743489077315
  },
  {
    'altitude' : 1168.9564029779285,
    'latitude' : 46.51794125499454,
    'longitude' : 11.53131525767382,
    'timestamp' : '2024-06-27T13:49:58Z'
  },
  {
    'altitude' : 1167.0078033069149,
    'longitude' : 11.531339319899065,
    'timestamp' : '2024-06-27T13:50:04Z',
    'latitude' : 46.518033220314294
  },
  {
    'longitude' : 11.531345941669436,
    'altitude' : 1163.9432316869497,
    'timestamp' : '2024-06-27T13:50:10Z',
    'latitude' : 46.51815730813347
  },
  {
    'timestamp' : '2024-06-27T13:50:18Z',
    'altitude' : 1161.3635381162167,
    'latitude' : 46.518222722818884,
    'longitude' : 11.531372012081828
  },
  {
    'timestamp' : '2024-06-27T13:50:31Z',
    'longitude' : 11.5313845673168,
    'altitude' : 1160.8645389499143,
    'latitude' : 46.5182756869583
  },
  {
    'longitude' : 11.531404843434236,
    'altitude' : 1159.0065019046888,
    'timestamp' : '2024-06-27T13:50:37Z',
    'latitude' : 46.51831846935636
  },
  {
    'altitude' : 1158.384512479417,
    'longitude' : 11.53138787794349,
    'timestamp' : '2024-06-27T13:50:43Z',
    'latitude' : 46.51836706236596
  },
  {
    'latitude' : 46.51841485040497,
    'timestamp' : '2024-06-27T13:50:49Z',
    'altitude' : 1157.978904264979,
    'longitude' : 11.531422511029113
  },
  {
    'longitude' : 11.531377672698216,
    'latitude' : 46.518447887172265,
    'timestamp' : '2024-06-27T13:50:55Z',
    'altitude' : 1158.1098763626069
  },
  {
    'longitude' : 11.531348097859935,
    'timestamp' : '2024-06-27T13:51:04Z',
    'altitude' : 1156.2551886001602,
    'latitude' : 46.518505601937996
  },
  {
    'longitude' : 11.531365496493125,
    'altitude' : 1156.1982345087454,
    'latitude' : 46.518573228124055,
    'timestamp' : '2024-06-27T13:51:10Z'
  },
  {
    'longitude' : 11.531303703715738,
    'altitude' : 1156.1856049997732,
    'latitude' : 46.51859841485824,
    'timestamp' : '2024-06-27T13:51:21Z'
  },
  {
    'latitude' : 46.518637100665345,
    'altitude' : 1154.657757894136,
    'longitude' : 11.531255389442437,
    'timestamp' : '2024-06-27T13:51:27Z'
  },
  {
    'latitude' : 46.51869325574432,
    'altitude' : 1153.8016590941697,
    'timestamp' : '2024-06-27T13:51:35Z',
    'longitude' : 11.531263335670237
  },
  {
    'latitude' : 46.51881238116703,
    'longitude' : 11.53123207525219,
    'timestamp' : '2024-06-27T13:51:44Z',
    'altitude' : 1150.9275789922103
  },
  {
    'latitude' : 46.51890650608641,
    'longitude' : 11.531146237973953,
    'altitude' : 1151.0967208370566,
    'timestamp' : '2024-06-27T13:51:50Z'
  },
  {
    'latitude' : 46.518967979993,
    'altitude' : 1148.6724369721487,
    'longitude' : 11.53108796679647,
    'timestamp' : '2024-06-27T13:51:56Z'
  },
  {
    'longitude' : 11.530982373592078,
    'latitude' : 46.519000650399455,
    'timestamp' : '2024-06-27T13:52:05Z',
    'altitude' : 1146.5866270521656
  },
  {
    'timestamp' : '2024-06-27T13:52:11Z',
    'altitude' : 1142.8164344523102,
    'latitude' : 46.51908058378826,
    'longitude' : 11.530857319696471
  },
  {
    'longitude' : 11.530979123333692,
    'latitude' : 46.51911729722114,
    'altitude' : 1142.8377737347037,
    'timestamp' : '2024-06-27T13:52:17Z'
  },
  {
    'timestamp' : '2024-06-27T13:52:23Z',
    'altitude' : 1143.441448240541,
    'latitude' : 46.5192211744153,
    'longitude' : 11.53102177539689
  },
  {
    'longitude' : 11.531015261140505,
    'timestamp' : '2024-06-27T13:52:29Z',
    'altitude' : 1144.0709334900603,
    'latitude' : 46.51928581542283
  },
  {
    'longitude' : 11.531010444989354,
    'timestamp' : '2024-06-27T13:52:38Z',
    'altitude' : 1143.466335524805,
    'latitude' : 46.519334887265714
  },
  {
    'altitude' : 1143.5918739018962,
    'latitude' : 46.5193857799331,
    'longitude' : 11.53100495582013,
    'timestamp' : '2024-06-27T13:52:48Z'
  },
  {
    'altitude' : 1143.6040148939937,
    'latitude' : 46.51946619103101,
    'longitude' : 11.530921657804932,
    'timestamp' : '2024-06-27T13:52:54Z'
  },
  {
    'altitude' : 1142.7963830335066,
    'timestamp' : '2024-06-27T13:53:00Z',
    'longitude' : 11.530831032759238,
    'latitude' : 46.519497169140045
  },
  {
    'timestamp' : '2024-06-27T13:53:06Z',
    'altitude' : 1140.314478396438,
    'latitude' : 46.519510020698654,
    'longitude' : 11.530762300668865
  },
  {
    'altitude' : 1139.5204940028489,
    'latitude' : 46.51949595575117,
    'timestamp' : '2024-06-27T13:53:12Z',
    'longitude' : 11.530671408907294
  },
  {
    'timestamp' : '2024-06-27T13:53:18Z',
    'altitude' : 1142.0493362732232,
    'longitude' : 11.530601596250143,
    'latitude' : 46.51951658649148
  },
  {
    'longitude' : 11.530537906750727,
    'timestamp' : '2024-06-27T13:53:24Z',
    'latitude' : 46.51956713641604,
    'altitude' : 1144.1889237761497
  },
  {
    'longitude' : 11.530521495727045,
    'timestamp' : '2024-06-27T13:53:30Z',
    'latitude' : 46.51963382632915,
    'altitude' : 1141.5991325117648
  },
  {
    'latitude' : 46.519672762033096,
    'altitude' : 1139.5507526015863,
    'longitude' : 11.530464963172331,
    'timestamp' : '2024-06-27T13:53:39Z'
  },
  {
    'latitude' : 46.51972094449865,
    'timestamp' : '2024-06-27T13:53:45Z',
    'altitude' : 1136.462063348852,
    'longitude' : 11.5304516493027
  },
  {
    'timestamp' : '2024-06-27T13:53:51Z',
    'latitude' : 46.51977629470696,
    'altitude' : 1134.1062383828685,
    'longitude' : 11.530386719274237
  },
  {
    'altitude' : 1133.30590170715,
    'longitude' : 11.530402165049919,
    'latitude' : 46.51982626695485,
    'timestamp' : '2024-06-27T13:53:57Z'
  },
  {
    'latitude' : 46.51991557032583,
    'longitude' : 11.53042825712279,
    'timestamp' : '2024-06-27T13:54:03Z',
    'altitude' : 1131.6882259557024
  },
  {
    'longitude' : 11.530369724537028,
    'altitude' : 1133.7700397437438,
    'latitude' : 46.51996699287744,
    'timestamp' : '2024-06-27T13:54:09Z'
  },
  {
    'timestamp' : '2024-06-27T13:54:15Z',
    'altitude' : 1132.4784493343905,
    'latitude' : 46.5199964087757,
    'longitude' : 11.53029470202292
  },
  {
    'altitude' : 1131.450136845,
    'longitude' : 11.53024492174444,
    'latitude' : 46.52007654813741,
    'timestamp' : '2024-06-27T13:54:21Z'
  },
  {
    'longitude' : 11.530184045941866,
    'latitude' : 46.52012273591126,
    'timestamp' : '2024-06-27T13:54:27Z',
    'altitude' : 1127.4008035846055
  },
  {
    'longitude' : 11.530122275517027,
    'latitude' : 46.52014219610484,
    'timestamp' : '2024-06-27T13:54:33Z',
    'altitude' : 1123.4949394902214
  },
  {
    'altitude' : 1121.1825354732573,
    'latitude' : 46.520213715994004,
    'longitude' : 11.530166772474418,
    'timestamp' : '2024-06-27T13:54:39Z'
  },
  {
    'longitude' : 11.530122304078485,
    'latitude' : 46.52026017545946,
    'timestamp' : '2024-06-27T13:54:47Z',
    'altitude' : 1120.0072835050523
  },
  {
    'timestamp' : '2024-06-27T13:54:53Z',
    'latitude' : 46.5202999871129,
    'altitude' : 1118.5245317211375,
    'longitude' : 11.53009156295495
  },
  {
    'latitude' : 46.52038319619115,
    'altitude' : 1116.453383171931,
    'timestamp' : '2024-06-27T13:54:59Z',
    'longitude' : 11.530075197029364
  },
  {
    'longitude' : 11.530002847177128,
    'latitude' : 46.52036353957313,
    'altitude' : 1114.8072028728202,
    'timestamp' : '2024-06-27T13:55:05Z'
  },
  {
    'altitude' : 1113.3503880919889,
    'longitude' : 11.529964649647553,
    'latitude' : 46.52040767126561,
    'timestamp' : '2024-06-27T13:55:11Z'
  },
  {
    'latitude' : 46.52045621244894,
    'longitude' : 11.529942891848359,
    'timestamp' : '2024-06-27T13:55:19Z',
    'altitude' : 1113.6182679012418
  },
  {
    'longitude' : 11.529862600357555,
    'altitude' : 1112.3564151171595,
    'timestamp' : '2024-06-27T13:55:25Z',
    'latitude' : 46.520450863723276
  },
  {
    'timestamp' : '2024-06-27T13:55:36Z',
    'latitude' : 46.52042963529903,
    'altitude' : 1112.9243233017623,
    'longitude' : 11.529791488128783
  },
  {
    'latitude' : 46.520398760991604,
    'timestamp' : '2024-06-27T13:55:42Z',
    'altitude' : 1111.034154488705,
    'longitude' : 11.529707241892416
  },
  {
    'altitude' : 1110.3569870209321,
    'longitude' : 11.529612796921395,
    'latitude' : 46.520429681003286,
    'timestamp' : '2024-06-27T13:55:50Z'
  },
  {
    'latitude' : 46.52050743374061,
    'longitude' : 11.52950854158947,
    'timestamp' : '2024-06-27T13:55:56Z',
    'altitude' : 1107.7826856039464
  },
  {
    'timestamp' : '2024-06-27T13:56:05Z',
    'longitude' : 11.529428661986213,
    'altitude' : 1106.4667073665187,
    'latitude' : 46.520521225274216
  },
  {
    'altitude' : 1107.6249125096947,
    'latitude' : 46.520558788737915,
    'longitude' : 11.529375930180032,
    'timestamp' : '2024-06-27T13:56:11Z'
  },
  {
    'altitude' : 1106.439600026235,
    'timestamp' : '2024-06-27T13:56:17Z',
    'longitude' : 11.529369816439516,
    'latitude' : 46.52061206710354
  },
  {
    'timestamp' : '2024-06-27T13:56:23Z',
    'altitude' : 1103.6703786738217,
    'longitude' : 11.529307864602927,
    'latitude' : 46.52065733724675
  },
  {
    'altitude' : 1106.0466978792101,
    'timestamp' : '2024-06-27T13:56:29Z',
    'latitude' : 46.52069591358047,
    'longitude' : 11.529255619256539
  },
  {
    'longitude' : 11.529178573273315,
    'timestamp' : '2024-06-27T13:56:35Z',
    'altitude' : 1103.6426546676084,
    'latitude' : 46.52079077978803
  },
  {
    'longitude' : 11.529125318307887,
    'latitude' : 46.52084244881748,
    'timestamp' : '2024-06-27T13:56:41Z',
    'altitude' : 1100.6528565445915
  },
  {
    'altitude' : 1098.599697586149,
    'latitude' : 46.520884705875844,
    'longitude' : 11.529032909852749,
    'timestamp' : '2024-06-27T13:56:47Z'
  },
  {
    'altitude' : 1097.9377768384293,
    'timestamp' : '2024-06-27T13:56:53Z',
    'longitude' : 11.528945044461821,
    'latitude' : 46.52093711669628
  },
  {
    'latitude' : 46.52097476593368,
    'altitude' : 1098.0508362352848,
    'longitude' : 11.528850817746662,
    'timestamp' : '2024-06-27T13:56:59Z'
  },
  {
    'altitude' : 1095.7410990959033,
    'timestamp' : '2024-06-27T13:57:05Z',
    'latitude' : 46.52102253921639,
    'longitude' : 11.52870001742647
  },
  {
    'longitude' : 11.52858204526196,
    'latitude' : 46.52104000568617,
    'altitude' : 1094.1705053299665,
    'timestamp' : '2024-06-27T13:57:11Z'
  },
  {
    'longitude' : 11.528485735734598,
    'latitude' : 46.52105347035739,
    'timestamp' : '2024-06-27T13:57:17Z',
    'altitude' : 1093.2452851254493
  },
  {
    'latitude' : 46.52109308960311,
    'longitude' : 11.52839696419247,
    'altitude' : 1093.7700329059735,
    'timestamp' : '2024-06-27T13:57:23Z'
  },
  {
    'longitude' : 11.528301248009985,
    'timestamp' : '2024-06-27T13:57:29Z',
    'altitude' : 1093.0533087374642,
    'latitude' : 46.52111234020422
  },
  {
    'longitude' : 11.528193642467917,
    'timestamp' : '2024-06-27T13:57:35Z',
    'latitude' : 46.52111941617315,
    'altitude' : 1092.2072012005374
  },
  {
    'latitude' : 46.52111178300866,
    'longitude' : 11.528096942491317,
    'altitude' : 1090.1146287601441,
    'timestamp' : '2024-06-27T13:57:41Z'
  },
  {
    'timestamp' : '2024-06-27T13:57:47Z',
    'latitude' : 46.52113319230025,
    'longitude' : 11.528008408658838,
    'altitude' : 1089.5634171627462
  },
  {
    'latitude' : 46.5211524032279,
    'longitude' : 11.527932045171509,
    'timestamp' : '2024-06-27T13:57:53Z',
    'altitude' : 1088.76030204352
  },
  {
    'altitude' : 1088.2781894486398,
    'latitude' : 46.521151111820636,
    'longitude' : 11.527854060673663,
    'timestamp' : '2024-06-27T13:57:58Z'
  },
  {
    'latitude' : 46.5211745985287,
    'longitude' : 11.52776520182227,
    'timestamp' : '2024-06-27T13:58:04Z',
    'altitude' : 1088.1440254673362
  },
  {
    'longitude' : 11.527678272950203,
    'timestamp' : '2024-06-27T13:58:09Z',
    'altitude' : 1086.4233882213011,
    'latitude' : 46.521193399732034
  },
  {
    'altitude' : 1085.852843691595,
    'latitude' : 46.52120928821296,
    'longitude' : 11.527582816815185,
    'timestamp' : '2024-06-27T13:58:15Z'
  },
  {
    'latitude' : 46.52120020702537,
    'longitude' : 11.527516594436618,
    'altitude' : 1084.3302333485335,
    'timestamp' : '2024-06-27T13:58:22Z'
  },
  {
    'altitude' : 1082.7640266167,
    'longitude' : 11.527410113107226,
    'timestamp' : '2024-06-27T13:58:28Z',
    'latitude' : 46.52118967270258
  },
  {
    'altitude' : 1082.233162199147,
    'latitude' : 46.521217944168335,
    'timestamp' : '2024-06-27T13:58:34Z',
    'longitude' : 11.527311935703185
  },
  {
    'altitude' : 1082.2507381578907,
    'latitude' : 46.52122266515996,
    'timestamp' : '2024-06-27T13:58:40Z',
    'longitude' : 11.52720722480539
  },
  {
    'timestamp' : '2024-06-27T13:58:46Z',
    'longitude' : 11.527120427123556,
    'altitude' : 1083.3450516294688,
    'latitude' : 46.52125559171356
  },
  {
    'longitude' : 11.526979942963694,
    'timestamp' : '2024-06-27T13:58:52Z',
    'latitude' : 46.521268438726324,
    'altitude' : 1082.0431468682364
  },
  {
    'latitude' : 46.52127767843243,
    'longitude' : 11.526882236961846,
    'timestamp' : '2024-06-27T13:58:58Z',
    'altitude' : 1082.0630549378693
  },
  {
    'latitude' : 46.52129510754804,
    'altitude' : 1080.0201322436333,
    'longitude' : 11.526740245627646,
    'timestamp' : '2024-06-27T13:59:04Z'
  },
  {
    'latitude' : 46.52130937875755,
    'longitude' : 11.526656430591778,
    'altitude' : 1081.21479042992,
    'timestamp' : '2024-06-27T13:59:10Z'
  },
  {
    'altitude' : 1080.0510449949652,
    'timestamp' : '2024-06-27T13:59:16Z',
    'latitude' : 46.52132710781855,
    'longitude' : 11.526533585229224
  },
  {
    'longitude' : 11.52643597046837,
    'latitude' : 46.521333863284774,
    'timestamp' : '2024-06-27T13:59:22Z',
    'altitude' : 1079.375679812394
  },
  {
    'timestamp' : '2024-06-27T13:59:28Z',
    'longitude' : 11.526343256388017,
    'latitude' : 46.5213401844586,
    'altitude' : 1078.945429184474
  },
  {
    'altitude' : 1078.0412272810936,
    'longitude' : 11.526217639507339,
    'latitude' : 46.52134855159,
    'timestamp' : '2024-06-27T13:59:34Z'
  },
  {
    'altitude' : 1076.4695125948638,
    'latitude' : 46.52134830611694,
    'timestamp' : '2024-06-27T13:59:40Z',
    'longitude' : 11.526084736138916
  },
  {
    'latitude' : 46.52137076333858,
    'altitude' : 1075.800139556639,
    'timestamp' : '2024-06-27T13:59:46Z',
    'longitude' : 11.525998711347277
  },
  {
    'altitude' : 1076.1278169043362,
    'latitude' : 46.52138065411473,
    'longitude' : 11.525932674097259,
    'timestamp' : '2024-06-27T13:59:52Z'
  },
  {
    'timestamp' : '2024-06-27T13:59:58Z',
    'longitude' : 11.525861679283688,
    'latitude' : 46.52137300636593,
    'altitude' : 1076.4037982197478
  },
  {
    'timestamp' : '2024-06-27T14:00:04Z',
    'longitude' : 11.525776896383444,
    'latitude' : 46.521381072973305,
    'altitude' : 1078.339357322082
  },
  {
    'longitude' : 11.525691288580184,
    'altitude' : 1078.822168304585,
    'timestamp' : '2024-06-27T14:00:10Z',
    'latitude' : 46.52137880865714
  },
  {
    'longitude' : 11.525625295573832,
    'altitude' : 1077.9478006055579,
    'latitude' : 46.52136097496639,
    'timestamp' : '2024-06-27T14:00:16Z'
  },
  {
    'altitude' : 1077.539291552268,
    'latitude' : 46.52131711042087,
    'longitude' : 11.525564711267146,
    'timestamp' : '2024-06-27T14:00:22Z'
  },
  {
    'altitude' : 1076.5855937395245,
    'latitude' : 46.52129156423117,
    'longitude' : 11.525473963798277,
    'timestamp' : '2024-06-27T14:00:28Z'
  },
  {
    'altitude' : 1075.6864277692512,
    'longitude' : 11.525347845578441,
    'latitude' : 46.52127399379813,
    'timestamp' : '2024-06-27T14:00:34Z'
  },
  {
    'latitude' : 46.52129048773292,
    'longitude' : 11.525227103755945,
    'timestamp' : '2024-06-27T14:00:40Z',
    'altitude' : 1075.4470124868676
  },
  {
    'altitude' : 1074.8537404118106,
    'latitude' : 46.52127558548627,
    'timestamp' : '2024-06-27T14:00:46Z',
    'longitude' : 11.525148700536203
  },
  {
    'altitude' : 1073.6779293203726,
    'latitude' : 46.52125058629732,
    'timestamp' : '2024-06-27T14:00:52Z',
    'longitude' : 11.525049021129393
  },
  {
    'latitude' : 46.52122586355308,
    'altitude' : 1072.851563807577,
    'longitude' : 11.524969908150549,
    'timestamp' : '2024-06-27T14:00:58Z'
  },
  {
    'longitude' : 11.524854386354493,
    'latitude' : 46.5212034269128,
    'timestamp' : '2024-06-27T14:01:04Z',
    'altitude' : 1073.2828094549477
  },
  {
    'timestamp' : '2024-06-27T14:01:10Z',
    'latitude' : 46.52118283382999,
    'altitude' : 1074.0597428744659,
    'longitude' : 11.524773610210474
  },
  {
    'latitude' : 46.52116691215675,
    'timestamp' : '2024-06-27T14:01:16Z',
    'altitude' : 1074.371406163089,
    'longitude' : 11.524702352343366
  },
  {
    'altitude' : 1073.5983950588852,
    'timestamp' : '2024-06-27T14:01:22Z',
    'longitude' : 11.524625253541636,
    'latitude' : 46.52116867840893
  },
  {
    'timestamp' : '2024-06-27T14:01:28Z',
    'longitude' : 11.524466275561473,
    'latitude' : 46.52115545673851,
    'altitude' : 1071.3759087705985
  },
  {
    'longitude' : 11.524348665244592,
    'timestamp' : '2024-06-27T14:01:34Z',
    'altitude' : 1070.4460794208571,
    'latitude' : 46.521140513395025
  },
  {
    'timestamp' : '2024-06-27T14:01:40Z',
    'longitude' : 11.524276750320942,
    'latitude' : 46.521130509615936,
    'altitude' : 1070.9020141968504
  },
  {
    'timestamp' : '2024-06-27T14:01:46Z',
    'altitude' : 1069.5354655859992,
    'longitude' : 11.524187739178595,
    'latitude' : 46.52109918942882
  },
  {
    'latitude' : 46.52109186688388,
    'timestamp' : '2024-06-27T14:01:52Z',
    'longitude' : 11.524098244027396,
    'altitude' : 1068.1513721365482
  },
  {
    'longitude' : 11.5240209511662,
    'latitude' : 46.52109493331556,
    'altitude' : 1068.4137139189988,
    'timestamp' : '2024-06-27T14:01:58Z'
  },
  {
    'longitude' : 11.523951070292673,
    'altitude' : 1067.7447638968006,
    'latitude' : 46.52106003785508,
    'timestamp' : '2024-06-27T14:02:03Z'
  },
  {
    'longitude' : 11.523857878877658,
    'altitude' : 1068.4271773472428,
    'latitude' : 46.52105578382614,
    'timestamp' : '2024-06-27T14:02:08Z'
  },
  {
    'altitude' : 1066.6070828149095,
    'timestamp' : '2024-06-27T14:02:14Z',
    'longitude' : 11.523780189663908,
    'latitude' : 46.521051418417244
  },
  {
    'latitude' : 46.52107510145664,
    'altitude' : 1065.384528271854,
    'timestamp' : '2024-06-27T14:02:20Z',
    'longitude' : 11.523679101632966
  },
  {
    'timestamp' : '2024-06-27T14:02:26Z',
    'latitude' : 46.52108868756042,
    'longitude' : 11.52356817997938,
    'altitude' : 1064.2219886053354
  },
  {
    'longitude' : 11.523429350278374,
    'timestamp' : '2024-06-27T14:02:32Z',
    'altitude' : 1063.1861040731892,
    'latitude' : 46.521108998666236
  },
  {
    'latitude' : 46.52112402055076,
    'timestamp' : '2024-06-27T14:02:38Z',
    'altitude' : 1062.3687758883461,
    'longitude' : 11.523343334038836
  },
  {
    'latitude' : 46.52113887159512,
    'longitude' : 11.52326451517745,
    'timestamp' : '2024-06-27T14:02:45Z',
    'altitude' : 1066.5938942851499
  },
  {
    'latitude' : 46.52115745238845,
    'longitude' : 11.523186450220978,
    'altitude' : 1063.803778600879,
    'timestamp' : '2024-06-27T14:02:51Z'
  },
  {
    'altitude' : 1062.6176619455218,
    'latitude' : 46.52116081654272,
    'longitude' : 11.523095826424418,
    'timestamp' : '2024-06-27T14:02:57Z'
  },
  {
    'latitude' : 46.52117123418246,
    'timestamp' : '2024-06-27T14:03:03Z',
    'longitude' : 11.522980444029042,
    'altitude' : 1059.877151163295
  },
  {
    'altitude' : 1056.5248070061207,
    'timestamp' : '2024-06-27T14:03:09Z',
    'longitude' : 11.522879333304063,
    'latitude' : 46.521200163801396
  },
  {
    'timestamp' : '2024-06-27T14:03:15Z',
    'altitude' : 1054.7743972549215,
    'longitude' : 11.522776079558106,
    'latitude' : 46.52121492051574
  },
  {
    'timestamp' : '2024-06-27T14:03:21Z',
    'latitude' : 46.52130080585278,
    'altitude' : 1054.5884512197226,
    'longitude' : 11.52277517318478
  },
  {
    'altitude' : 1054.513429241255,
    'longitude' : 11.522816310458767,
    'timestamp' : '2024-06-27T14:03:27Z',
    'latitude' : 46.52136599153306
  },
  {
    'longitude' : 11.522866952436853,
    'latitude' : 46.52139865993683,
    'altitude' : 1054.71761368867,
    'timestamp' : '2024-06-27T14:03:33Z'
  },
  {
    'latitude' : 46.52146002933498,
    'timestamp' : '2024-06-27T14:03:39Z',
    'longitude' : 11.52290937538597,
    'altitude' : 1056.0275229848921
  },
  {
    'longitude' : 11.52303926702199,
    'altitude' : 1054.6394189186394,
    'latitude' : 46.52150358766057,
    'timestamp' : '2024-06-27T14:03:45Z'
  },
  {
    'longitude' : 11.523127709634524,
    'latitude' : 46.521535545789696,
    'altitude' : 1055.645854394883,
    'timestamp' : '2024-06-27T14:03:51Z'
  },
  {
    'latitude' : 46.52156132941908,
    'timestamp' : '2024-06-27T14:03:57Z',
    'altitude' : 1056.0274481652305,
    'longitude' : 11.523248881070359
  },
  {
    'latitude' : 46.52160417794492,
    'timestamp' : '2024-06-27T14:04:03Z',
    'longitude' : 11.523309869606251,
    'altitude' : 1056.631711567752
  },
  {
    'longitude' : 11.523331840307858,
    'timestamp' : '2024-06-27T14:04:09Z',
    'latitude' : 46.52165905893411,
    'altitude' : 1055.5614812094718
  },
  {
    'longitude' : 11.52342324582117,
    'altitude' : 1055.2580753816292,
    'latitude' : 46.52171306405996,
    'timestamp' : '2024-06-27T14:04:15Z'
  },
  {
    'longitude' : 11.523506094300485,
    'timestamp' : '2024-06-27T14:04:21Z',
    'latitude' : 46.521744959823906,
    'altitude' : 1054.642599761486
  },
  {
    'altitude' : 1055.5977792767808,
    'timestamp' : '2024-06-27T14:04:26Z',
    'longitude' : 11.523530047258333,
    'latitude' : 46.52180073617874
  },
  {
    'altitude' : 1055.5082287415862,
    'longitude' : 11.52362135723488,
    'latitude' : 46.52184199335376,
    'timestamp' : '2024-06-27T14:04:32Z'
  },
  {
    'longitude' : 11.523688062502979,
    'latitude' : 46.52190765099345,
    'timestamp' : '2024-06-27T14:04:38Z',
    'altitude' : 1056.0351836485788
  },
  {
    'longitude' : 11.523772148062728,
    'timestamp' : '2024-06-27T14:04:44Z',
    'latitude' : 46.521945323768534,
    'altitude' : 1055.6801037201658
  },
  {
    'altitude' : 1056.6322889355943,
    'latitude' : 46.522020716097295,
    'longitude' : 11.523824195919673,
    'timestamp' : '2024-06-27T14:04:50Z'
  },
  {
    'latitude' : 46.522099890717975,
    'longitude' : 11.523894121795015,
    'altitude' : 1057.7548243859783,
    'timestamp' : '2024-06-27T14:04:56Z'
  },
  {
    'latitude' : 46.522133941229164,
    'longitude' : 11.52395299835308,
    'altitude' : 1055.9257237166166,
    'timestamp' : '2024-06-27T14:05:03Z'
  },
  {
    'timestamp' : '2024-06-27T14:05:09Z',
    'longitude' : 11.524036761833482,
    'altitude' : 1059.1762800831348,
    'latitude' : 46.52218010617017
  },
  {
    'longitude' : 11.524031953692672,
    'altitude' : 1060.16565401759,
    'timestamp' : '2024-06-27T14:05:15Z',
    'latitude' : 46.52226464785602
  },
  {
    'altitude' : 1059.406096288003,
    'timestamp' : '2024-06-27T14:05:21Z',
    'longitude' : 11.52411854117041,
    'latitude' : 46.52233558454301
  },
  {
    'altitude' : 1057.8607261124998,
    'longitude' : 11.524161241241373,
    'timestamp' : '2024-06-27T14:05:27Z',
    'latitude' : 46.52240637578028
  },
  {
    'latitude' : 46.52248037313192,
    'timestamp' : '2024-06-27T14:05:33Z',
    'longitude' : 11.524182165560504,
    'altitude' : 1056.762177290395
  },
  {
    'altitude' : 1057.9871903788298,
    'longitude' : 11.524189021024359,
    'latitude' : 46.522559060140495,
    'timestamp' : '2024-06-27T14:05:39Z'
  },
  {
    'longitude' : 11.524209380981794,
    'latitude' : 46.52264232981761,
    'timestamp' : '2024-06-27T14:05:45Z',
    'altitude' : 1057.7864765385166
  },
  {
    'longitude' : 11.524238324429815,
    'altitude' : 1058.2195007624105,
    'timestamp' : '2024-06-27T14:05:51Z',
    'latitude' : 46.52269990325018
  },
  {
    'latitude' : 46.52275422330578,
    'longitude' : 11.524286166453091,
    'altitude' : 1058.038242782466,
    'timestamp' : '2024-06-27T14:05:57Z'
  },
  {
    'altitude' : 1058.2623725393787,
    'longitude' : 11.524316892028008,
    'latitude' : 46.52281457824041,
    'timestamp' : '2024-06-27T14:06:03Z'
  },
  {
    'latitude' : 46.52288337674276,
    'timestamp' : '2024-06-27T14:06:09Z',
    'longitude' : 11.524383725558005,
    'altitude' : 1058.1285331966355
  },
  {
    'altitude' : 1057.9838224444538,
    'latitude' : 46.522953974179906,
    'timestamp' : '2024-06-27T14:06:15Z',
    'longitude' : 11.524422226177023
  },
  {
    'latitude' : 46.52302504605473,
    'longitude' : 11.524485699951379,
    'timestamp' : '2024-06-27T14:06:21Z',
    'altitude' : 1059.508496134542
  },
  {
    'altitude' : 1058.2373546501622,
    'latitude' : 46.52310602525071,
    'timestamp' : '2024-06-27T14:06:27Z',
    'longitude' : 11.524508219225124
  },
  {
    'altitude' : 1057.8457007044926,
    'latitude' : 46.52317216679404,
    'longitude' : 11.524467164949511,
    'timestamp' : '2024-06-27T14:06:32Z'
  },
  {
    'timestamp' : '2024-06-27T14:06:38Z',
    'longitude' : 11.524470233666275,
    'latitude' : 46.52324266273618,
    'altitude' : 1056.693949079141
  },
  {
    'longitude' : 11.524494996851093,
    'latitude' : 46.52331649350654,
    'altitude' : 1057.1337021775544,
    'timestamp' : '2024-06-27T14:06:44Z'
  },
  {
    'longitude' : 11.524482460344174,
    'altitude' : 1057.1337185800076,
    'latitude' : 46.523364182453264,
    'timestamp' : '2024-06-27T14:06:50Z'
  },
  {
    'latitude' : 46.52341068895337,
    'timestamp' : '2024-06-27T14:06:56Z',
    'altitude' : 1058.1849939841777,
    'longitude' : 11.524499278169433
  },
  {
    'longitude' : 11.524470853390262,
    'timestamp' : '2024-06-27T14:07:02Z',
    'altitude' : 1058.8848015908152,
    'latitude' : 46.52347229399478
  },
  {
    'latitude' : 46.52352170419345,
    'altitude' : 1059.562370058149,
    'timestamp' : '2024-06-27T14:07:08Z',
    'longitude' : 11.524458948116473
  },
  {
    'timestamp' : '2024-06-27T14:07:14Z',
    'latitude' : 46.523587385885236,
    'altitude' : 1059.4351098397747,
    'longitude' : 11.524415873658564
  },
  {
    'longitude' : 11.524503856131041,
    'latitude' : 46.52359194613757,
    'altitude' : 1054.7068534037098,
    'timestamp' : '2024-06-27T14:07:29Z'
  },
  {
    'latitude' : 46.52360725311014,
    'timestamp' : '2024-06-27T14:07:44Z',
    'longitude' : 11.524342948490299,
    'altitude' : 1054.4640009915456
  }
]

""";
    
    static func getSample() -> TrackpointList {
        let data =  sample.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do{
            let result:TrackpointList = try decoder.decode(TrackpointList.self, from : data)
            return result
        }
        catch (let err){
            Log.error(error: err)
        }
        return TrackpointList()
    }
}
