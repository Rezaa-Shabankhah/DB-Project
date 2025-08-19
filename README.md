## معرفی کلی پروژه

این پروژه یک ORM ساده برای SQLite است که با هدف آموزش اصول اولیه نگاشت کلاس‌های پایتون به جداول دیتابیس طراحی شده است.
کد اصلی در `orm_simple.py` قرار دارد و تست‌ها در `tests_orm.py` نگهداری می‌شوند.

### مراحل اجرا :

دستورات زیر از دایرکتری اصلی فایل‌ها اجرا شود :

```
python3 -m venv venv
source venv/bin/activate

# هیچ پکیج خارجی لازم نیست. در صورت تمایل فقط برای گزارش پوشش تست:
# pip install coverage

# اجرای تست‌ها
python -m unittest tests_orm.py

# اجرای تست‌ها با coverage:
# coverage run -m unittest tests_orm.py && coverage report -m
```

## ساختار کلی پروژه

پروژه در سه بخش اصلی تقسیم شده است:

* **orm\_simple.py**: هسته ORM شامل کلاس‌های Field، BaseModel، ForeignKeyField و مدل‌های مثال Passenger, Flight, Ticket
* **tests\_orm.py**: تست‌های واحد با unittest برای پوشش CRUD و اعتبارسنجی و بررسی کلیدهای خارجی
* **نمونه اسکریپت‌ها یا REPL**: مثال‌های استفاده و ایجاد/خواندن رکوردها (اختیاری)

### معماری پایگاه داده

* جدول **passengers**: اطلاعات پایه مسافر شامل person\_id، first\_name، last\_name، customer\_points
* جدول **flights**: اطلاعات پرواز شامل flight\_id، flight\_time، replacement\_flight\_id، airplane\_id
* جدول **tickets**: بلیط‌ها که شامل id، flight\_id (FK به flights)، passenger\_id (FK به passengers)، seat\_number، price

در این نسخه کلیدهای خارجی به‌صورت واقعی اعلام و هنگام ساخت جدول `FOREIGN KEY(... ) REFERENCES ... ON DELETE CASCADE` تولید می‌شوند و همچنین در زمان ذخیره رکورد، وجود ردیف مرجع بررسی می‌گردد.

### تنظیمات پایگاه داده:

پروژه از ماژول استاندارد `sqlite3` پایتون استفاده می‌کند. هنگام ایجاد اتصال با `BaseModel.connect(path)` مقدار پیشفرض `":memory:"` است. قابلیت‌ها:

* `conn.row_factory = sqlite3.Row` برای دسترسی شبیه دیکشنری به ردیف‌ها.
* اجرای `PRAGMA foreign_keys = ON;` برای فعال‌سازی قوانین FK در SQLite.
* امکان استفاده از فایل DB با دادن مسیر به `BaseModel.connect("db.sqlite")`.

### طراحی Models:

تمام مدل‌ها از `BaseModel` ارث می‌برند. هر مدل فیلدهایش را با نمونه‌هایی از `IntegerField`, `CharField`, یا `ForeignKeyField` تعریف می‌کند. متاکلاس `ModelMeta` هنگام تعریف کلاس:

* فیلدها را جمع‌آوری و در `_fields` نگه می‌دارد.
* نام جدول را (به صورت پیشفرض اسم کلاس جمع‌شده) تعیین می‌کند.

- نمونه فیلدها و نقش‌ها:

  * **IntegerField**: عدد صحیح با گزینه‌های primary\_key و autoincrement و default
  * **CharField**: متن با max\_length و null و unique
  * **ForeignKeyField**: اشاره‌گر به مدل دیگر. دارای گزینه `on_delete_cascade` که به‌صورت پیشفرض فعال است.

### رفتارهای مهم ORM

* ایجاد خودکار جدول: `Model.create_table()` براساس فیلدها SQL مناسب تولید و اجرا می‌کند. در صورت وجود FK، clause های `FOREIGN KEY` همراه با `ON DELETE CASCADE` اضافه می‌شوند.
* عملیات CRUD:

  * `save()` : قبل از نوشتن همه فیلدها را اعتبارسنجی می‌کند. در صورت وجود FK بررسی می‌کند که ردیف مرجع وجود داشته باشد. اگر PK مقدار نداشت، INSERT و در صورت autoincrement گرفتن lastrowid انجام می‌شود. در غیر اینصورت UPDATE انجام می‌شود.
  * `get(**kwargs)` : یک رکورد مطابق شروط برمی‌گرداند یا None.
  * `delete()` : حذف بر اساس PK.
* اعتبارسنجی ساده قبل از ذخیره:

  * Nullability، نوع داده (int/str)، طول متن بررسی می‌شود.
  * خطاها با `ValidationError` گزارش می‌شوند.
* مدیریت اتصال:

  * اتصال یک‌باره و اشتراکی از طریق `BaseModel.connect(path)` ایجاد می‌شود. اتصال برای همه مدل‌ها مشترک است.

### نکات عملی

* اگر بخواهید رکورد مرجع حذف شود و رکورد وابسته نیز خودکار حذف شود، `ForeignKeyField` به‌صورت پیشفرض `ON DELETE CASCADE` فعال است.
* اگر می‌خواهید رفتار متفاوتی (مثل RESTRICT) داشته باشید می‌توانید `on_delete_cascade=False` هنگام تعریف `ForeignKeyField` قرار دهید.

### تست‌ها

تست‌ها در `tests_orm.py` با `unittest` نوشته شده‌اند و شامل موارد زیر است:

* CRUD پایه برای Passenger
* ایجاد Flight و Ticket و بررسی لینک FK
* اعتبارسنجی نوع و null
* آزمایش عدم امکان درج Ticket با FK ناموجود (اطمینان از enforcement)

اجرای تست:

```
python -m unittest tests_orm.py
```

## نکات فنی پیاده‌سازی

* تابع `BaseModel.connect` برای برقراری اتصال مرکزی با پایگاه داده طراحی شده است. این تابع `PRAGMA foreign_keys = ON` را اجرا می‌کند تا SQLite قوانین FK را رعایت کند.

>

* کد از parameterized queries (`?` placeholders) برای جلوگیری از SQL injection استفاده می‌کند. اعتبارسنجی ورودی‌ها در سطح application انجام می‌شود و کلیدهای خارجی روابط جداول را حفظ می‌کنند.

>

* سیستم شامل مکانیزم‌های پایه‌ای برای مدیریت خطا است، از جمله:

  * `ValidationError` برای خطاهای اعتبارسنجی.
  * تبدیل خطاهای یکپارچگی SQLite به `ValidationError` با پیام قابل‌فهم.
  * بررسی وجود رکورد مرجع قبل از درج برای ارائه پیام خطای مفید به کاربر.

```
```
