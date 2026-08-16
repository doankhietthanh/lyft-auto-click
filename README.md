# Lyft Auto Click

Script tự động quét khu vực trên ứng dụng Lyft, phát hiện chuyến mới và thử
nhấn Reserve bằng nhận diện hình ảnh.

> Chỉ sử dụng trên thiết bị, tài khoản và môi trường mà bạn được phép tự động
> hóa. Hãy kiểm tra điều khoản của Lyft trước khi sử dụng.

## Luồng hoạt động

Script chạy liên tục cho đến khi click được toàn bộ chuỗi Reserve:

1. Vuốt sang phải.
2. Ngay sau swipe, ưu tiên kiểm tra `new_available_rides`. Nếu đã xuất hiện,
   xử lý Reserve ngay và không click Search Area để tránh làm mất ride.
3. Nếu chưa có ride, tìm và click `search_this_area` đúng một lần. Click này
   kích hoạt API tìm chuyến ở khu vực mới.
4. Chờ API trả về `new_available_rides`.
5. Nếu tìm thấy, lần lượt click `new_available_rides`, `btn_reserve`, và
   `btn_reserve_confirm`.
6. Chỉ dừng vòng lặp khi cả ba click trên đều thành công. Nếu một click thất
   bại hoặc API không có kết quả, vuốt sang trái và lặp lại.

Trình tự vuốt và thời gian chờ của một chu kỳ là:

```text
Vuốt phải
  -> chờ UI settle 150 ms
  -> probe new_available_rides ngay lập tức
  -> nếu chưa có: find/click search_this_area tối đa 6 lần, dừng ngay khi click được
  -> chờ API trả kết quả 500 ms
  -> probe new_available_rides một lần
  -> click ride -> Reserve -> Confirm
Vuốt trái
  -> chờ UI settle 150 ms
  -> probe new_available_rides ngay lập tức
  -> nếu chưa có: find/click search_this_area tối đa 6 lần, dừng ngay khi click được
  -> chờ API trả kết quả 500 ms
  -> probe new_available_rides một lần
  -> click ride -> Reserve -> Confirm
  -> lặp lại
```

## Các ảnh nhận diện

Các tên ảnh được tham chiếu trong script phải tồn tại trong thư viện ảnh của
công cụ tự động click:

| Tên ảnh | Vai trò |
| --- | --- |
| `search_this_area` | Nút yêu cầu tìm lại chuyến trong khu vực hiện tại |
| `new_available_rides` | Dấu hiệu có chuyến mới |
| `btn_reserve` | Nút Reserve sau khi mở chuyến |
| `btn_reserve_confirm` | Nút xác nhận Reserve |

Ảnh minh họa thư viện nhận diện nằm tại [`resources/overview.png`](resources/overview.png).

## Tham số nhận diện

```text
findFastParam = timeout 1000 ms, match score 0.85
priorityRideParam = timeout 50 ms, match score 0.85
reserveParam  = timeout 1500 ms, match score 0.85
searchAreaClickParam = timeout 250 ms, match score 0.85
swipeSettleDelay = 50 ms
apiResultDelay = 500 ms
pollInterval = 75 ms
searchAreaAttempts = 6
```

- `search_this_area` được click lại cho từng swipe; không có trạng thái nào
  được giữ lại giữa hai swipe.
- Script chờ 50 ms sau swipe để animation/map trên device thật ổn định trước
  khi nhận diện Search Area, và chờ 500 ms sau click Search Area cho API
  trả kết quả.
- `new_available_rides` được probe ưu tiên với timeout 50 ms trước Search Area,
  sau đó probe lại một lần sau cửa sổ API. Điều này tránh Search Area ghi đè
  ride đã xuất hiện.
- `btn_reserve` có thời gian tìm dài hơn vì màn hình chi tiết cần thời gian
  hiển thị.
- `btn_reserve_confirm` cũng dùng timeout 1.5 giây, để chờ màn hình xác nhận.
- `search_this_area` và `new_available_rides` có hai pha riêng: tìm/click để
  gọi API trước, rồi mới poll kết quả API.
- Tất cả thao tác tìm/nhấn yêu cầu điểm tương đồng tối thiểu 0.85.
- `search_this_area` dùng vùng riêng `Region.deviceReg().center()`, tức khu
  vực trung tâm màn hình.
- `new_available_rides`, `btn_reserve`, và `btn_reserve_confirm` tiếp tục dùng
  `Region.deviceReg().bottom()`.

Việc script dừng nghĩa là ba thao tác click đã trả về thành công. Để xác minh
việc đặt chuyến thực sự hoàn tất trên Lyft, hãy bổ sung một template trạng thái
thành công riêng nếu UI có hiển thị trạng thái đó.

## Cấu hình thao tác vuốt

Script dùng tọa độ cố định trên màn hình:

```text
Vuốt phải: (500, 1000) -> (750, 1000) trong 120 ms
Vuốt trái: (750, 1000) -> (500, 1000) trong 120 ms
```

Các tọa độ này phụ thuộc kích thước và tỉ lệ màn hình. Nếu thiết bị khác độ
phân giải, cần điều chỉnh `goLeft()` và `goRight()` trước khi chạy.

## Chạy script

1. Mở công cụ auto-click hỗ trợ cú pháp trong [`main.txt`](main.txt).
2. Đảm bảo các ảnh nhận diện đã được khai báo đúng tên.
3. Kết nối thiết bị và mở đúng màn hình Lyft cần quét.
4. Chạy `main.txt`.
5. Dừng script thủ công khi không muốn tiếp tục quét.

Script không có điều kiện timeout tổng thể; nếu không tìm thấy chuyến, nó sẽ
tiếp tục vuốt và tìm lại khu vực vô hạn.

## Cấu trúc repository

```text
.
├── main.txt                 # Script chính
├── test.txt                 # Biến thể dùng để kiểm tra luồng
└── resources/
    └── overview.png         # Ảnh tổng quan các template nhận diện
```

## Kiểm tra flow

Chạy `zsh tests/main-flow.test.zsh` để kiểm tra tĩnh các điều kiện không được
hồi quy: Search Area luôn chạy trước lúc poll kết quả API, không có trạng thái
Search Area xuyên qua các swipe, và chuỗi thành công phải kiểm tra click
Confirm. Test này không thay thế việc chạy thử trên thiết bị thật.
