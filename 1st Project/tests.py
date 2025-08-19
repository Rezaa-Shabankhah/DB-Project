import unittest
import os
import sqlite3
from orm2 import BaseModel, Passenger, Flight, Ticket, ValidationError


class ORMTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        BaseModel.connect(":memory:")  # in-memory database for tests

        Passenger.create_table()
        Flight.create_table()
        Ticket.create_table()

    def test_passenger_crud(self):
        p = Passenger(first_name="Ali", last_name="Reza", customer_points=100)
        p.save()
        self.assertIsNotNone(p.person_id)
        pid = p.person_id

        p2 = Passenger.get(person_id=pid)
        self.assertIsNotNone(p2)
        self.assertEqual(p2.first_name, "Ali")

        p2.first_name = "Alireza"
        p2.save()
        p3 = Passenger.get(person_id=pid)
        self.assertEqual(p3.first_name, "Alireza")

        p3.delete()
        self.assertIsNone(Passenger.get(person_id=pid))

    def test_flight_and_ticket(self):
        f = Flight(flight_time="2025-08-20 10:00", replacement_flight_id=None, airplane_id=1)
        f.save()
        self.assertIsNotNone(f.flight_id)

        p = Passenger(first_name="Sara", last_name="Khan", customer_points=0)
        p.save()
        self.assertIsNotNone(p.person_id)

        t = Ticket(flight_id=f.flight_id, passenger_id=p.person_id, seat_number="12A", price=199)
        t.save()
        self.assertIsNotNone(t.id)

        t2 = Ticket.get(id=t.id)
        self.assertEqual(t2.seat_number, "12A")

    def test_validation(self):
        with self.assertRaises(ValidationError):
            p = Passenger(first_name=None, last_name="NoFirstName")
            p.save()

        with self.assertRaises(ValidationError):  # type mismatch
            f = Flight(flight_time=12345, replacement_flight_id=None, airplane_id=2)
            f.save()


if __name__ == "__main__":
    unittest.main()
