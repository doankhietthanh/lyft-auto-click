# Lyft Auto Click

Script tự động quét khu vực trên ứng dụng Lyft, phát hiện chuyến mới và thử
nhấn Reserve bằng nhận diện hình ảnh.

> Chỉ sử dụng trên thiết bị, tài khoản và môi trường mà bạn được phép tự động
> hóa. Hãy kiểm tra điều khoản của Lyft trước khi sử dụng.

## Luồng hoạt động

Script chạy liên tục cho đến khi click được toàn bộ chuỗi Reserve:

1. Vuốt sang phải.
2. Ngay sau swipe, ưu tiên click `new_available_rides` ngay lập tức (50 ms). Nếu có chuyến, thực hiện chuỗi Reserve và dừng chu kỳ swipe hiện tại để tránh mất ride.
3. Nếu chưa có ride, click `search_this_area` (quét liên tục tối đa 1200 ms). Click này kích hoạt API tìm chuyến ở khu vực mới.
4. Quét liên tục `new_available_rides` đón đầu kết quả API (tối đa 700 ms). Ngay khi server trả về và UI render, script click ngay lập tức không có độ trễ mù.
5. Khi click mở chuyến thành công, lần lượt click `btn_reserve` và `btn_reserve_confirm`.
6. Chỉ dừng vòng lặp chính khi cả ba click trên đều thành công. Nếu thất bại hoặc API không có kết quả, vuốt sang trái và lặp lại.

Trình tự vuốt và thời gian chờ của một chu kỳ là:

```text
Vuốt phải
  -> chờ UI settle 200 ms
  -> click probe new_available_rides ngay lập tức (50 ms)
  -> nếu chưa có: click search_this_area (quét liên tục tối đa 1200 ms)
  -> click probe new_available_rides đón đầu API (tối đa 700 ms, nhận diện là click ngay)
  -> khi mở chuyến: click btn_reserve -> btn_reserve_confirm
Vuốt trái
  -> chờ UI settle 200 ms
  -> click probe new_available_rides ngay lập tức (50 ms)
  -> nếu chưa có: click search_this_area (quét liên tục tối đa 1200 ms)
  -> click probe new_available_rides đón đầu API (tối đa 700 ms, nhận diện là click ngay)
  -> khi mở chuyến: click btn_reserve -> btn_reserve_confirm
  -> lặp lại
```

## Các ảnh nhận diện

Các tên ảnh được tham chiếu trong script phải tồn tại trong thư viện ảnh của
công cụ tự động click:

| Tên ảnh               | Vai trò                                            |
| --------------------- | -------------------------------------------------- |
| `search_this_area`    | Nút yêu cầu tìm lại chuyến trong khu vực hiện tại  |
| `new_available_rides` | Dấu hiệu có chuyến mới                             |
| `btn_reserve`         | Nút Reserve sau khi mở chuyến                      |
| `btn_reserve_confirm` | Nút xác nhận Reserve                               |

Ảnh minh họa thư viện nhận diện nằm tại [`resources/overview.png`](resources/overview.png).

## Tham số nhận diện

```text
priorityRideParam = timeout 50 ms, match score 0.85
postSearchRideParam = timeout 700 ms, match score 0.85
btnReserveParam = timeout 500 ms, match score 0.85
btnConfirmParam = timeout 500 ms, match score 0.85
searchAreaClickParam = timeout 1200 ms, match score 0.85
swipeSettleDelay = 200 ms
```

- `search_this_area` được click lại cho từng swipe; không có trạng thái nào
  được giữ lại giữa hai swipe.
- Script chờ 200 ms sau swipe để animation/map trên device thật ổn định trước
  khi nhận diện.
- `new_available_rides` được click trực tiếp với timeout 50 ms trước Search Area; nếu có chuyến sẽ tap ngay mà không quét lặp `find()` 2 lần.
- `search_this_area` được quét liên tục với timeout 1200 ms, loại bỏ vòng lặp thủ công và khoảng trễ chết `wait()`.
- `postSearchRideParam` (700 ms) kết hợp cả thời gian chờ API phản hồi lẫn quét liên tục; ngay khi chuyến xuất hiện sẽ click ngay lập tức thay vì sleep mù cố định.
- `btn_reserve` và `btn_reserve_confirm` có cấu hình timeout riêng 500 ms để tinh chỉnh độc lập.
- Tất cả thao tác tìm/nhấn yêu cầu điểm tương đồng tối thiểu 0.85.
- `search_this_area` dùng vùng riêng `Region.deviceReg().middle()`, tức khu
  vực trung tâm màn hình.
- `new_available_rides`, `btn_reserve`, và `btn_reserve_confirm` dùng
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
hồi quy: ride được ưu tiên trước Search Area, không có trạng thái
Search Area xuyên qua các swipe, và chuỗi thành công phải kiểm tra click
Confirm. Test này không thay thế việc chạy thử trên thiết bị thật.
