## معرفی کلی پروژه

این پروژه یک ORM ساده برای SQLite و با هدف نگاشت کلاس‌های پایتون به جداول دیتابیس طراحی شده است.

### مراحل اجرا :

دستورات زیر از دایرکتری اصلی فایل‌ها اجرا شود :

```
pip install coverage
coverage run -m unittest tests.py && coverage report -m
```

## ساختار کلی پروژه

پروژه در دو بخش اصلی تقسیم شده است:

* فایل **orm2.py**: هسته ORM شامل کلاس‌های Field، BaseModel، ForeignKeyField و مدل‌های مثال Passenger, Flight, Ticket
* فایل **tests.py**: تست‌های واحد با unittest برای پوشش CRUD

### معماری پایگاه داده

* جدول **passengers**: اطلاعات پایه مسافر شامل person_id، first_name، last_name، customer_points
* جدول **flights**: اطلاعات پرواز شامل flight_id، flight_time، replacement_flight_id، airplane_id
* جدول **tickets**: بلیط‌ها که شامل id، flight_id ، passenger_id، seat_number، price


### تنظیمات پایگاه داده:

پروژه از ماژول استاندارد `sqlite3` پایتون استفاده می‌کند. هنگام ایجاد اتصال با `BaseModel.connect(path)` مقدار پیشفرض `":memory:"` است. قابلیت‌ها:

*  برای دسترسی شبیه دیکشنری به ردیف‌ها `conn.row_factory = sqlite3.Row`
* امکان استفاده از فایل DB با دادن مسیر به `BaseModel.connect("db.sqlite")`

### طراحی Models:

تمام مدل‌ها از `BaseModel` ارث می‌برند. هر مدل فیلدهایش را با نمونه‌هایی از `IntegerField`, `CharField`, یا `ForeignKeyField` تعریف می‌کند. متاکلاس `ModelMeta` هنگام تعریف کلاس:

* فیلدها را جمع‌آوری و در `_fields` نگه می‌دارد.
* نام جدول را (به صورت پیشفرض اسم کلاس جمع‌شده) تعیین می‌کند.

- نمونه فیلدها و نقش‌ها:

  * **IntegerField**:
  عدد صحیح با گزینه‌های primary\_key و autoincrement و default
  * **CharField**:
  متن با max\_length و null و unique
  * **ForeignKeyField**:
 اشاره‌گر به مدل دیگر. دارای گزینه `on_delete_cascade` که به‌صورت پیشفرض فعال است.

### رفتارهای مهم ORM

* ایجاد خودکار جدول: `Model.create_table()` براساس فیلدها SQL مناسب تولید و اجرا می‌کند.
* عملیات CRUD:

  * `save()` :
  قبل از نوشتن همه فیلدها را اعتبارسنجی می‌کند. اگر PK مقدار نداشت، INSERT و در صورت autoincrement گرفتن lastrowid انجام می‌شود. در غیر اینصورت UPDATE انجام می‌شود.
  * `get(**kwargs)` :
  یک رکورد مطابق شروط برمی‌گرداند یا None.
  * `delete()` :
  حذف بر اساس PK.

* اعتبارسنجی ساده قبل از ذخیره:

   * هم Nullability و هم نوع داده (int/str) و طول متن بررسی می‌شود.
   * خطاها با `ValidationError` گزارش می‌شوند.
   
* مدیریت اتصال:

   * اتصال یک‌باره و اشتراکی از طریق `BaseModel.connect(path)` ایجاد می‌شود. اتصال برای همه مدل‌ها مشترک است.


### تست‌ها

تست‌ها در `tests.py` با `unittest` نوشته شده‌اند و شامل موارد زیر است:

* اعمال CRUD پایه برای Passenger
* ایجاد Flight و Ticket
* اعتبارسنجی نوع و null

اجرای تست:

```
python -m unittest tests.py
```

## نکات فنی پیاده‌سازی

- تابع `BaseModel.connect` برای برقراری اتصال مرکزی با پایگاه داده طراحی شده است.

- کد از parameterized queries (`?` placeholders) برای جلوگیری از SQL injection استفاده می‌کند. اعتبارسنجی ورودی‌ها در سطح application انجام می‌شود.
 
- سیستم شامل مکانیزم‌های پایه‌ای برای مدیریت خطا است، از جمله:
    *‌ مکانیزم `ValidationError` برای خطاهای اعتبارسنجی.
    * تبدیل خطاهای یکپارچگی SQLite به `ValidationError` با پیام قابل‌فهم.
    * بررسی وجود رکورد مرجع قبل از درج برای ارائه پیام خطای مفید به کاربر.
