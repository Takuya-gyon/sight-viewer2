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
}

void draw() {
  background(0);
  
  println(imgHeight, height);
  
  //現在の視線データの経過時間を取得
  int gazeTime = gazeData.getInt(currentStep, 0);
  
  // 現在の視線データの位置を取得
  int[] gazePos = new int[]{gazeData.getInt(currentStep, 1), gazeData.getInt(currentStep, 2)};
  
  println(gazeTime, gazePos[0], gazePos[1]);

  int x = (gazePos[1]) * imgWidth / gridCols; // 列からマーカーのx座標を計算
  int y = (gazePos[0]) * imgHeight / gridRows; // 行からマーカーのy座標を計算
  
  //image(codeImage, 0, -(gazePos[1] / pageRows) * pageHeight, imgWidth, imgHeight); // プログラム画像を描画
  image(codeImage, 0, 0, imgWidth, imgHeight); // プログラム画像を描画
  
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
}
