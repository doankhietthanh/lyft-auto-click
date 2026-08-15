# Lyft Auto Click

Script tự động quét khu vực trên ứng dụng Lyft, phát hiện chuyến mới và thử
nhấn Reserve bằng nhận diện hình ảnh.

> Chỉ sử dụng trên thiết bị, tài khoản và môi trường mà bạn được phép tự động
> hóa. Hãy kiểm tra điều khoản của Lyft trước khi sử dụng.

## Luồng hoạt động

Script chạy liên tục cho đến khi phát hiện được một chuyến:

1. Vuốt sang phải.
2. Tìm ảnh `new_available_rides` trong vùng popup phía dưới màn hình.
3. Nếu tìm thấy:
   - Nhấn `new_available_rides`.
   - Thử tìm và nhấn `btn_reserve` trong tối đa 1.5 giây.
   - Dừng vòng lặp.
4. Nếu chưa tìm thấy, tiếp tục kiểm tra mỗi 50 ms trong 200 ms.
5. Nhấn `search_this_area` để yêu cầu Lyft tìm lại khu vực.
6. Kiểm tra ngay, sau đó tiếp tục kiểm tra mỗi 50 ms trong 300 ms.
7. Vuốt sang trái và lặp lại các bước kiểm tra/chờ/tìm lại khu vực.

Trình tự vuốt và thời gian chờ của một chu kỳ là:

```text
Vuốt phải
  -> kiểm tra ngay -> chờ 200 ms
  -> search_this_area
  -> kiểm tra ngay -> chờ 300 ms
Vuốt trái
  -> kiểm tra ngay -> chờ 200 ms
  -> search_this_area
  -> kiểm tra ngay -> chờ 300 ms
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

Ảnh minh họa thư viện nhận diện nằm tại [`resources/overview.png`](resources/overview.png).

## Tham số nhận diện

```text
findFastParam = timeout 50 ms, match score 0.85
reserveParam  = timeout 1500 ms, match score 0.85
searchArea    = timeout 300 ms, match score 0.85
```

- `new_available_rides` được tìm nhanh với timeout 50 ms.
- `btn_reserve` có thời gian tìm dài hơn vì màn hình chi tiết cần thời gian
  hiển thị.
- Tất cả thao tác tìm/nhấn yêu cầu điểm tương đồng tối thiểu 0.85.
- Vùng tìm kiếm là `Region.deviceReg().bottom()`, tức phần dưới màn hình.

## Cấu hình thao tác vuốt

Script dùng tọa độ cố định trên màn hình:

```text
Vuốt phải: (500, 1200) -> (750, 1200) trong 100 ms
Vuốt trái: (750, 1200) -> (500, 1200) trong 100 ms
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

## Lưu ý về `test.txt`

`test.txt` hiện có cùng luồng với `main.txt`, nhưng bổ sung thao tác nhấn
`btn_reserve_confirm` sau khi nhấn `btn_reserve`. README này mô tả chính xác
luồng của `main.txt`; nếu cần xác nhận Reserve tự động, phải thêm template
`btn_reserve_confirm` và thao tác xác nhận vào script chính.
