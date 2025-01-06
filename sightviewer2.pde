PImage codeImage;       // プログラム画像
int gridRows = 148;      // 画像を分割する行数
int gridCols = 86;      // 画像を分割する列数

int currentStep;    // 現在の視線データのステップ
int imgWidth, imgHeight; //表示画像のサイズ
int cellWidth, cellHeight; // マス目のサイズ

Table gazeData; //視線データ大元
int gazeCount; //視線データのサンプリング数
int gazeEndTime; //視線データの末端データにおける経過時間

int pageRows = 30;
int pageHeight;

boolean ifAuto;

String folderName = "gazes";
int fileCount;
int fileStep;
File folder;
File[] files;

HashMap<String, String> q_scores; //採点結果の辞書

int[][] heatmap; // ヒートマップデータ用2次元配列     AJNI

void setup() {
  //フォント設定（日本語表示に対応するため）
  PFont font = createFont("Meiryo", 50);
  textFont(font);

  fullScreen(2);
  //size(800, 600);
  surface.setResizable(true); // ウィンドウのサイズを可変にする
  
  // 問題正答ファイルを読み込み、辞書に値を保存
  q_scores = new HashMap<String, String>();
  loadCsvToDictionary("q_score1d.csv", q_scores);
  
   // フォルダ内の画像ファイルを取得
  folder = new File(dataPath(folderName));
  if (!folder.exists()) {
    println("フォルダが見つかりません: " + folderName);
    exit();
  }
  files = folder.listFiles();
  fileCount = files.length;
  if (fileCount <= 0) {
    println("データがありません");
    exit();
  }
  fileStep = 0;
  
  //背景画像関連の変数を初期化
  codeImage = loadImage("Main4.png"); // プログラム画像を読み込む
  imgWidth = codeImage.width * height / codeImage.height; //画像の幅
  imgHeight = height; //画像の高さ
  cellWidth = imgWidth / gridCols;     // 各マスの幅
  cellHeight = imgHeight / gridRows;   // 各マスの高さ
  
  //pageHeight = pageRows * cellHeight; 
  
  gazeDataInit();
  
  ifAuto = false; //自動再生かどうか（初期設定：手動）
  
  
  //AJNI
  heatmap = new int[gridRows][gridCols]; // 行と列ごとの視線滞在回数を記録
  //AJNI
}

void draw() {
  background(0);
  
  //println(imgHeight, height); AJNI
  
  //現在の視線データの経過時間を取得
  int gazeTime = gazeData.getInt(currentStep, 0);
  
  // 現在の視線データの位置を取得
  int[] gazePos = new int[]{gazeData.getInt(currentStep, 1), gazeData.getInt(currentStep, 2)};
  //AJNI
  // ヒートマップデータを更新
  if (gazePos[0] >= 0 && gazePos[0] < gridRows && gazePos[1] >= 0 && gazePos[1] < gridCols) {
    heatmap[gazePos[0]][gazePos[1]]++; // 視線滞在回数をカウント
  }
    
  image(codeImage, 0, 0, imgWidth, imgHeight); // プログラム画像を描画  //println(gazeTime, gazePos[0], gazePos[1]); AJNI

  int x = (gazePos[1]) * imgWidth / gridCols; // 列からマーカーのx座標を計算
  int y = (gazePos[0]) * imgHeight / gridRows; // 行からマーカーのy座標を計算
  //AJNI
  fill(255, 0, 0, 150); // 半透明の赤いマーカー
  noStroke();
  rect(x, y, cellWidth, cellHeight);
  //image(codeImage, 0, -(gazePos[1] / pageRows) * pageHeight, imgWidth, imgHeight); // プログラム画像を描画
  //image(codeImage, 0, 0, imgWidth, imgHeight); // プログラム画像を描画  AJNI
  
  // ヒートマップの描画
  drawHeatmap();
  //AJNI
  
  //ファイル名を描画
  fill(255);
  textSize(50);
  String filename = files[fileStep].getName();
  String personQuestion = removeExtension(filename);
  String person = split(personQuestion, "-")[0];
  String question = split(personQuestion, "-")[1];
  String scoreText;
  scoreText = q_scores.get(personQuestion);
  if(question.equals("q4")) { scoreText = "name：" + q_scores.get(person+"-q4_1") + ", age：" + q_scores.get(person+"-q4_2"); }
  text("現在のファイル：" + filename + "\n正答：" +  scoreText, 300, 50);
  
  
  // マーカーを描画
  fill(255, 0, 0, 150); // 半透明の赤いマーカー
  noStroke();
  rect(x, y, cellWidth, cellHeight);
  
  //シークバーを描画
  int barHeight = 30; 
  fill(0, 0, 0, 150);
  rect(0, height - barHeight, width, barHeight);
  fill(255, 0, 0, 150);
  rect(0, height - barHeight, width * gazeTime / gazeEndTime, barHeight);
  
  // 自動再生時の処理
  if (ifAuto) { 
    currentStep++;
    
    //最後まで行ったときの処理
    if (currentStep >= gazeCount - 1) {
      currentStep = 0; // ステップを最初に戻す
      
      delay(3000); //3秒停止し、最初から再生
      
      return;
    }
    
    //最後以外の時、次のデータまで停止
    delay(gazeData.getInt(currentStep + 1, 0) - gazeTime);
  }
  
  fill(0);
  rect(width, height, 100, 100);
}

void gazeDataInit() {
  gazeData = loadTable(folderName + "/" + files[fileStep].getName(), "header");
  gazeCount = gazeData.getRowCount();
  gazeEndTime = gazeData.getInt(gazeCount - 1, 0);
  
  currentStep = 0;
}

void keyPressed() {
  if (keyCode == RIGHT) { // 右キーが押された場合
    currentStep++;
    
    if (currentStep >= gazeCount) { currentStep = gazeCount - 1; }
  }
  if (keyCode == LEFT) {
    currentStep--;
    
    if (currentStep < 0) { currentStep = 0; }
  }
  if(keyCode == DOWN){
    currentStep = gazeCount - 1;
  }
  if(keyCode == UP){
    currentStep = 0;
  }
  if(key == 'd'){
    fileStep++;
    
    if(fileStep >= fileCount){ fileStep = fileCount - 1; }
    
    gazeDataInit();
  }
  if(key == 'a'){
        fileStep--;
    
    if(fileStep < 0){ fileStep = 0; }
    
    gazeDataInit();
  }
  if (key == 'l') {
    ifAuto = !ifAuto;
  }
}

// CSVを読み込み、HashMapに保存する関数
void loadCsvToDictionary(String filePath, HashMap<String, String> dictionary) {
  // CSVファイルを行ごとに読み込む
  String[] rows = loadStrings(filePath);
  
  // 各行を処理
  for (String row : rows) {
    // 行をカンマで分割
    String[] keyValue = split(row, ',');
    
    // キーと値を辞書に保存
    if (keyValue.length == 2) {
      dictionary.put(keyValue[0].trim(), keyValue[1].trim());
    }
  }
}

//AJNI
void drawHeatmap() {
  noStroke();
  for (int row = 0; row < gridRows; row++) {
    for (int col = 0; col < gridCols; col++) {
      int x = col * cellWidth;
      int y = row * cellHeight;
      
      // 視線滞在回数を色の濃度に変換（最大値を基準に正規化）
      float alpha = map(heatmap[row][col], 0, getMaxHeatmapValue(), 0, 255);
      
      // カラー設定（赤をベースに濃度を設定）
      fill(255, 0, 0, alpha);
      rect(x, y, cellWidth, cellHeight);
    }
  }
}

int getMaxHeatmapValue() {
  int maxVal = 0;
  for (int row = 0; row < gridRows; row++) {
    for (int col = 0; col < gridCols; col++) {
      if (heatmap[row][col] > maxVal) {
        maxVal = heatmap[row][col];
      }
    }
  }
  return maxVal;
}

//ファイル名から拡張子を除く関数
String removeExtension(String filename) {
  int dotIndex = filename.lastIndexOf(".");
  if (dotIndex > 0) {
    return filename.substring(0, dotIndex);
  }
  return filename;  // 拡張子がない場合はそのまま返す
}
