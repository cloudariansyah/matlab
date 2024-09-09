function image_analysis_gui
   % Buat figure utama dengan warna latar belakang
   hFig = figure('Name', 'Analisis Citra', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1000, 600], 'MenuBar', 'none', ...
                 'Resize', 'off', 'Color', [0.9, 0.9, 0.9]);
   
   % Buat axes untuk menampilkan gambar dengan batas dan warna latar belakang
   hAxes1 = axes('Parent', hFig, 'Position', [0.05, 0.25, 0.3, 0.4], ...
                 'Color', [1, 1, 1], 'Box', 'on');
   hAxes2 = axes('Parent', hFig, 'Position', [0.4, 0.55, 0.3, 0.4], ...
                 'Color', [1, 1, 1], 'Box', 'on');
   hAxes3 = axes('Parent', hFig, 'Position', [0.4, 0.05, 0.3, 0.4], ...
                 'Color', [1, 1, 1], 'Box', 'on');
   
   % Label untuk setiap axes
   uicontrol('Style', 'text', 'String', 'Gambar Asli', ...
             'Position', [100, 320, 150, 25], 'BackgroundColor', [0.9, 0.9, 0.9], 'FontSize', 12);
  uicontrol('Style', 'text', 'String', 'Hasil Contrast Stretching', ...
          'Position', [500, 450, 150, 25], 'BackgroundColor', [0.9, 0.9, 0.9], 'FontSize', 12);

   uicontrol('Style', 'text', 'String', 'Hasil Histogram Equalization', ...
             'Position', [500, 80, 150, 25], 'BackgroundColor', [0.9, 0.9, 0.9], 'FontSize', 12);

   % Buat tombol untuk memuat gambar dan turunkan sedikit
   uicontrol('Style', 'pushbutton', 'String', 'Ambil Gambar', ...
             'Position', [50, 500, 150, 40], 'Callback', @loadImage, ...
             'BackgroundColor', [0.5, 0.7, 0.9], 'FontSize', 12);
   
   % Buat tombol untuk generate output (Contrast Stretching dan Equalasi Histogram)
   uicontrol('Style', 'pushbutton', 'String', 'Generate Output', ...
             'Position', [50, 460, 150, 40], 'Callback', @generateOutput, ...
             'BackgroundColor', [0.7, 0.9, 0.5], 'FontSize', 12);
   
   % Tambahkan progress bar/loading bar
   hProgressBar = uicontrol('Style', 'text', 'Position', [50, 420, 150, 30], ...
                            'String', '', 'BackgroundColor', [0.8, 0.8, 0.8], ...
                            'FontSize', 12, 'HorizontalAlignment', 'center');
   
   % Tambahkan tombol "Download" untuk mengunduh semua hasil
   uicontrol('Style', 'pushbutton', 'String', 'Download Semua Hasil', ...
             'Position', [790, 55, 150, 40], 'Callback', @downloadAllResults, ...
             'BackgroundColor', [0.8, 0.8, 0.8], 'FontSize', 12);
   
   % Buat checkbox untuk konversi RGB ke Grayscale
   hCheckbox = uicontrol('Style', 'checkbox', 'String', 'RGB ke Greyscale', ...
                         'Position', [50, 100, 150, 30], 'BackgroundColor', [0.9, 0.9, 0.9], ...
                         'FontSize', 12);

   % Variabel untuk menyimpan gambar asli dan gambar yang diproses
   originalImage = [];
   processedImage_CS = [];
   processedImage_HE = [];
   
   % Fungsi callback untuk memuat gambar
   function loadImage(~, ~)
       [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', 'File Gambar'});
       if isequal(filename, 0)
           return;
       end
       [~, ~, ext] = fileparts(filename);
       if ~ismember(ext, {'.jpg', '.png', '.bmp'})
           errordlg('Format gambar tidak sesuai. Silakan pilih file dengan format .jpg, .png, atau .bmp.');
           return;
       end
       originalImage = imread(fullfile(pathname, filename));
       imshow(originalImage, 'Parent', hAxes1);
   end
   
   % Fungsi callback untuk generate output dan menampilkan progress bar
   function generateOutput(~, ~)
       if isempty(originalImage)
           errordlg('Ambil gambar terlebih dahulu.');
           return;
       end
       set(hProgressBar, 'String', 'Memproses...');
       pause(1); % Simulasi waktu pemrosesan

       img = originalImage;
       if get(hCheckbox, 'Value')
           img = rgb2gray(img);
       end

       % Proses Contrast Stretching
       c = double(min(img(:)));
       d = double(max(img(:)));
       L = 256; % Untuk gambar grayscale 8-bit
       processedImage_CS = im2double(img);
       processedImage_CS = (processedImage_CS - c) / (d - c) * (L - 1);
       processedImage_CS = uint8(processedImage_CS * (L - 1));
       imshow(processedImage_CS, 'Parent', hAxes2);

       % Proses Histogram Equalization
       processedImage_HE = histeq(img, 256);
       imshow(processedImage_HE, 'Parent', hAxes3);

       set(hProgressBar, 'String', 'Selesai!');
   end

     % Fungsi untuk mengunduh semua hasil
   function downloadAllResults(~, ~)
       if isempty(processedImage_CS) || isempty(processedImage_HE)
           errordlg('Tidak ada gambar yang dihasilkan. Pastikan Anda telah meng-generate output.');
           return;
       end
       
       % Ambil timestamp saat ini
       timestamp = datestr(now, 'yyyymmdd_HHMMSS');
       
       % Simpan gambar dengan nama file yang berisi timestamp
       imwrite(processedImage_CS, ['Contrast_Stretching_Result_' timestamp '.png']);
       imwrite(processedImage_HE, ['Histogram_Equalization_Result_' timestamp '.png']);
       
       msgbox('Semua gambar hasil telah diunduh ke local disk.');
   end

end
