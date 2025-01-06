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


int[][] heatmap; // ヒートマップデータ用2次元配列     AJNI

void setup() {
  //フォント設定（日本語表示に対応するため）
  PFont font = createFont("Meiryo", 50);
  textFont(font);

  fullScreen(2);
  //size(800, 600);
  surface.setResizable(true); // ウィンドウのサイズを可変にする
  
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
  for (int i = 0; i < fileCount; i++) {
    processAndSaveHeatmap(i); // 各ファイルごとにヒートマップを処理し保存
  }

  gazeDataInit();
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
  text("現在のファイル：" + files[fileStep].getName(), 300, 50);
  
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
  
  //AJNI
   if (key == 'f') {
    displayAllHeatmaps(); // fキーで全ヒートマップを表示
  }
  //AJNI
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

int getMaxHeatmapValue() {//指定されたヒートマップ配列内の最大値を取得します。
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

void processAndSaveHeatmap(int fileIndex) {
  // ファイルごとに視線データを処理してヒートマップを保存
  Table currentGazeData = loadTable(folderName + "/" + files[fileIndex].getName(), "header");
  int[][] currentHeatmap = new int[gridRows][gridCols];

  int currentGazeCount = currentGazeData.getRowCount();
  for (int j = 0; j < currentGazeCount; j++) {
    int row = currentGazeData.getInt(j, 1);
    int col = currentGazeData.getInt(j, 2);
    if (row >= 0 && row < gridRows && col >= 0 && col < gridCols) {
      currentHeatmap[row][col]++;
    }
  }
  saveHeatmap(currentHeatmap, files[fileIndex].getName());
}

void saveHeatmap(int[][] heatmap, String filename) {// ヒートマップデータを画像として保存します
  PGraphics pg = createGraphics(imgWidth, imgHeight);
  pg.beginDraw();
  pg.image(codeImage, 0, 0, imgWidth, imgHeight);

  for (int row = 0; row < gridRows; row++) {
    for (int col = 0; col < gridCols; col++) {
      int x = col * cellWidth;
      int y = row * cellHeight;
      float alpha = map(heatmap[row][col], 0, getMaxValue(heatmap), 0, 255);
      pg.fill(255, 0, 0, alpha);
      pg.noStroke();
      pg.rect(x, y, cellWidth, cellHeight);
    }
  }
  pg.endDraw();
  pg.save("heatmap_" + filename + ".png");
}

void displayAllHeatmaps() {
  int totalWidth = imgWidth * fileCount;
  PGraphics pg = createGraphics(totalWidth, imgHeight);
  
  pg.beginDraw();
  for (int i = 0; i < fileCount; i++) {
    PImage heatmapImage = loadImage("heatmap_" + files[i].getName() + ".png");
    pg.image(heatmapImage, i * imgWidth, 0);
  }
  pg.endDraw();
  
  // フルスクリーンに描画
  image(pg, 0, 0, width, height);
}

int getMaxValue(int[][] heatmap) {//指定されたヒートマップ配列内の最大値を取得します。
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
