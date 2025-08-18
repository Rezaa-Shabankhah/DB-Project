import os
import sys
import sqlite3
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from orm import Database, Model, IntegerField, CharField, BooleanField, ValidationError, DoesNotExist

TEST_DB = 'test_db.sqlite3'

class User(Model):
    id = IntegerField(primary_key=True)
    username = CharField(unique=True, max_length=50)
    age = IntegerField(default=0, null=False)
    is_active = BooleanField(default=True)

class ORMTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if os.path.exists(TEST_DB):
            os.remove(TEST_DB)
        Database.connect(TEST_DB)
        User._create_table()

    @classmethod
    def tearDownClass(cls):
        conn = Database.get_conn()
        conn.close()
        if os.path.exists(TEST_DB):
            os.remove(TEST_DB)

    def setUp(self):
        Database.execute('DELETE FROM user')

    def test_create_and_get(self):
        u = User.create(username='alice', age=30)
        self.assertIsNotNone(u._data.get('id'))
        fetched = User.get(username='alice')
        self.assertEqual(fetched._data['username'], 'alice')
        self.assertEqual(fetched._data['age'], 30)

    def test_unique_constraint(self):
        User.create(username='bob')
        with self.assertRaises(ValidationError):
            User.create(username='bob')

    def test_update(self):
        u = User.create(username='carol', age=20)
        u.update(age=21)
        fetched = User.get(username='carol')
        self.assertEqual(fetched._data['age'], 21)

    def test_delete(self):
        u = User.create(username='dave')
        uid = u._data.get('id')
        u.delete()
        with self.assertRaises(DoesNotExist):
            User.get(id=uid)

    def test_validation(self):
        with self.assertRaises(ValidationError):
            User.create(username=None)
        with self.assertRaises(ValidationError):
            User.create(username='x'*1000)
        with self.assertRaises(ValidationError):
            u = User.create(username='eve')
            u.update(age='not int')

    def test_filter(self):
        User.create(username='alice', age=25)
        User.create(username='bob', age=30)
        results = User.filter(age=25)
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]._data['username'], 'alice')

    def test_default_values(self):
        u = User.create(username='test')
        self.assertEqual(u._data['age'], 0)
        self.assertTrue(u._data['is_active'])

    def test_boolean_field(self):
        u = User.create(username='bool_test', is_active=False)
        fetched = User.get(username='bool_test')
        self.assertFalse(fetched._data['is_active'])

    def test_to_dict(self):
        u = User.create(username='dict_test', age=35)
        data = u.to_dict()
        self.assertIn('username', data)
        self.assertEqual(data['username'], 'dict_test')
        self.assertEqual(data['age'], 35)

    def test_update_nonexistent_field(self):
        u = User.create(username='field_test')
        with self.assertRaises(AttributeError):
            u.update(nonexistent_field='value')

if __name__ == '__main__':
    unittest.main()
