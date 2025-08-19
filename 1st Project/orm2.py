import sqlite3
from typing import Any, Dict, Type


class ValidationError(Exception):
    pass


class Field:
    def __init__(self, null: bool = False, unique: bool = False, default: Any = None, primary_key: bool = False):
        self.name = None
        self.null = null
        self.unique = unique
        self.default = default
        self.primary_key = primary_key

    def get_sql(self):
        raise NotImplementedError

    def validate(self, value):
        if value is None:
            if not self.null and not self.primary_key:
                raise ValidationError(f"Field '{self.name}' cannot be null.")
            return True
        return True


class IntegerField(Field):
    def __init__(self, null: bool = False, unique: bool = False, default: Any = None, primary_key: bool = False, autoincrement: bool = False):
        super().__init__(null=null, unique=unique, default=default, primary_key=primary_key)
        self.autoincrement = autoincrement

    def get_sql(self):
        parts = []
        if self.primary_key:
            if self.autoincrement:
                parts.append("INTEGER PRIMARY KEY AUTOINCREMENT")
            else:
                parts.append("INTEGER PRIMARY KEY")
        else:
            parts.append("INTEGER")
            if not self.null:
                parts.append("NOT NULL")
        if self.unique:
            parts.append("UNIQUE")
        if self.default is not None:
            parts.append(f"DEFAULT {self.default}")
        return " ".join(parts)

    def validate(self, value):
        super().validate(value)
        if value is None:
            return True
        if not isinstance(value, int):
            raise ValidationError(f"Field '{self.name}' expects int but got {type(value).__name__}.")
        return True


class CharField(Field):
    def __init__(self, max_length: int = 255, null: bool = False, unique: bool = False, default: Any = None, primary_key: bool = False):
        super().__init__(null=null, unique=unique, default=default, primary_key=primary_key)
        self.max_length = max_length

    def get_sql(self):
        parts = [f"TEXT"]
        if not self.null:
            parts.append("NOT NULL")
        if self.unique:
            parts.append("UNIQUE")
        if self.default is not None:
            parts.append(f"DEFAULT '{self.default}'")
        return " ".join(parts)

    def validate(self, value):
        super().validate(value)
        if value is None:
            return True
        if not isinstance(value, str):
            raise ValidationError(f"Field '{self.name}' expects str but got {type(value).__name__}.")
        if len(value) > self.max_length:
            raise ValidationError(f"Field '{self.name}' exceeds max_length {self.max_length}.")
        return True


class ModelMeta(type):
    def __new__(cls, name, bases, attrs):
        if name == "BaseModel":
            return super().__new__(cls, name, bases, attrs)
        fields = {}
        for key, value in list(attrs.items()):
            if isinstance(value, Field):
                value.name = key
                fields[key] = value
                attrs.pop(key)
        attrs["_fields"] = fields
        if "table_name" not in attrs:
            attrs["table_name"] = name.lower() + "s"
        return super().__new__(cls, name, bases, attrs)


class BaseModel(metaclass=ModelMeta):
    _connection: sqlite3.Connection = None

    @classmethod
    def connect(cls, path=":memory:"):
        if cls._connection is None:
            conn = sqlite3.connect(path)
            conn.row_factory = sqlite3.Row
            cls._connection = conn
        return cls._connection

    @classmethod
    def cursor(cls):
        if cls._connection is None:
            raise RuntimeError("Database not connected. Call BaseModel.connect(path) first.")
        return cls._connection.cursor()

    @classmethod
    def create_table(cls):
        cols = []
        for name, field in cls._fields.items():
            sql = f'"{name}" {field.get_sql()}'
            cols.append(sql)
        sql = f'CREATE TABLE IF NOT EXISTS "{cls.table_name}" ({", ".join(cols)});'
        cur = cls.cursor()
        cur.execute(sql)
        cls._connection.commit()

    def __init__(self, **kwargs):
        for name, field in self._fields.items():
            value = kwargs.get(name, field.default)
            setattr(self, name, value)

    def to_dict(self):
        return {name: getattr(self, name) for name in self._fields.keys()}

    @classmethod
    def _get_pk_field(cls):
        for name, field in cls._fields.items():
            if field.primary_key:
                return name, field
        return None, None

    def save(self):
        for name, field in self._fields.items():
            value = getattr(self, name)
            field.validate(value)
        self.connect()

        pk_name, pk_field = self._get_pk_field()
        cur = self.cursor()

        if pk_name is None:
            cols = []
            vals = []
            placeholders = []
            for name, field in self._fields.items():
                value = getattr(self, name)
                if value is None and field.default is not None:
                    value = field.default
                cols.append(f'"{name}"')
                vals.append(value)
                placeholders.append("?")
            sql = f'INSERT INTO "{self.table_name}" ({", ".join(cols)}) VALUES ({", ".join(placeholders)})'
            cur.execute(sql, vals)
            self._connection.commit()
            return

        pk_value = getattr(self, pk_name)
        if pk_value is None:
            cols = []
            vals = []
            placeholders = []
            for name, field in self._fields.items():
                if name == pk_name and isinstance(field, IntegerField) and field.autoincrement:
                    continue
                value = getattr(self, name)
                if value is None and field.default is not None:
                    value = field.default
                    setattr(self, name, value)
                cols.append(f'"{name}"')
                vals.append(value)
                placeholders.append("?")
            sql = f'INSERT INTO "{self.table_name}" ({", ".join(cols)}) VALUES ({", ".join(placeholders)})'
            try:
                cur.execute(sql, vals)
            except sqlite3.IntegrityError as e:
                raise ValidationError(str(e))
            if isinstance(pk_field, IntegerField) and pk_field.autoincrement:
                last = cur.lastrowid
                setattr(self, pk_name, last)
            self._connection.commit()
        else:
            cols = []
            vals = []
            for name, field in self._fields.items():
                if name == pk_name:
                    continue
                cols.append(f'"{name}" = ?')
                vals.append(getattr(self, name))
            vals.append(pk_value)
            sql = f'UPDATE "{self.table_name}" SET {", ".join(cols)} WHERE "{pk_name}" = ?'
            cur.execute(sql, vals)
            if cur.rowcount == 0:
                raise RuntimeError("Update failed. No row with given primary key.")
            self._connection.commit()

    @classmethod
    def get(cls, **kwargs):
        cls.connect()
        cur = cls.cursor()
        where = []
        vals = []
        for k, v in kwargs.items():
            if k not in cls._fields:
                raise KeyError(f"Unknown field '{k}' for model {cls.__name__}.")
            where.append(f'"{k}" = ?')
            vals.append(v)
        sql = f'SELECT * FROM "{cls.table_name}" WHERE {" AND ".join(where)} LIMIT 1'
        cur.execute(sql, vals)
        row = cur.fetchone()
        if row is None:
            return None
        data = {col: row[col] for col in row.keys()}
        return cls(**data)

    def delete(self):
        pk_name, pk_field = self._get_pk_field()
        if pk_name is None:
            raise RuntimeError("Delete requires a primary key on the model.")
        pk_value = getattr(self, pk_name)
        if pk_value is None:
            raise RuntimeError("Instance has no primary key value. Cannot delete.")
        cur = self.cursor()
        sql = f'DELETE FROM "{self.table_name}" WHERE "{pk_name}" = ?'
        cur.execute(sql, (pk_value,))
        self._connection.commit()


class Passenger(BaseModel):
    table_name = "passengers"
    person_id = IntegerField(primary_key=True, autoincrement=True)
    first_name = CharField(max_length=127, null=False)
    last_name = CharField(max_length=127, null=False)
    customer_points = IntegerField(null=True, default=0)


class Flight(BaseModel):
    table_name = "flights"
    flight_id = IntegerField(primary_key=True, autoincrement=True)
    flight_time = CharField(max_length=64, null=False)
    replacement_flight_id = IntegerField(null=True)
    airplane_id = IntegerField(null=False)


class Ticket(BaseModel):
    table_name = "tickets"
    id = IntegerField(primary_key=True, autoincrement=True)
    flight_id = IntegerField(null=False)
    passenger_id = IntegerField(null=False)
    seat_number = CharField(max_length=16, null=False)
    price = IntegerField(null=False)
