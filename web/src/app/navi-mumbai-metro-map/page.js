import React from "react";

const NaviMumbaiMetroMap = () => {
  return (
    <>
      <div className="page-heading-section">
        <span className="page-heading text-4xl">Navi Mumbai Metro Map</span>
      </div>
      <iframe
        title="Navi Mumbai Metro Map"
        src="https://www.google.com/maps/d/u/0/embed?mid=1ID2BEAYf5WROOG7Z-4VG8EVF_vgulyQ&ehbc=2E312F&noprof=1"
        className=" px-10 w-full h-screen"
      ></iframe>
      <div className="page-container mx-auto">
        <div className="lg:col-span-12 mt-4 mb-4">
          <h1 className="text-3xl font-bold mb-4">
            Navi Mumbai Metro Information
          </h1>

          <section className="mb-8">
            <h2 className="text-xl font-bold mb-2">Operational Line</h2>
            <h3 className="text-lg font-bold mb-2">
              Line-1: CBD Belapur – Pendhar
            </h3>
            <ul className="list-disc pl-4">
              <li>Length: 11.10 km</li>
              <li>Estimated Cost: Rs. 3063.63 cr</li>
              <li>Type: Elevated</li>
              <li>Depot: Taloja</li>
              <li>Number of Stations: 11</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-bold mb-2">Future Network</h2>

            <div className="mb-4">
              <h3 className="text-lg font-bold mb-2">
                Line-2: Taloje MIDC – Khandeshwar
              </h3>
              <p>
                <strong>Note:</strong> This line is an extension of Line-1
              </p>
              <ul className="list-disc pl-4">
                <li>Estimated Cost: Rs. 2820.20 cr</li>
                <li>Length: 7.12 km</li>
                <li>Type: Elevated</li>
                <li>Number of Stations: 6</li>
              </ul>
            </div>

            <div className="mb-4">
              <h3 className="text-lg font-bold mb-2">
                Line-3: Taloje MIDC – Pendhar
              </h3>
              <p>
                <strong>Note:</strong>This line is an extension of Line-1
              </p>
              <ul className="list-disc pl-4">
                <li>Estimated Cost: Rs. 1750.14 cr</li>
                <li>Length: 3.87 km</li>
                <li>Type: Elevated</li>
                <li>Number of Stations: 3</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-bold mb-2">
                Line-4: Khandeshwar – Navi Mumbai International Airport (NMIA)
              </h3>
              <p>
                <strong>Note:</strong> This line is an extension of Line-1
              </p>
              <ul className="list-disc pl-4">
                <li>Estimated Cost: Rs. 1270.17 cr</li>
                <li>Length: 4.17 km</li>
                <li>Type: Elevated & Underground</li>
              </ul>
            </div>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-2">System Specifications</h2>
            <ul className="list-disc pl-4">
              <li>Top Speed: 80 kmph</li>
              <li>Average Speed: 34 kmph</li>
            </ul>
          </section>

          <section className="mt-8">
            <h2 className="text-xl font-bold mb-2">Key Figures</h2>
            <p>
              Operational: 11.1 km | Under Construction: 0 km | Proposed: 95.30
              km
            </p>
          </section>

          <section className="mt-8">
            <h1 className="text-3xl font-bold mb-4">
              Navi Mumbai Metro Fares (Ticket Prices)
            </h1>

            <p>Fares are dependent on the distance traveled:</p>
            <ul className="list-disc pl-4 mb-8">
              <li>Rs. 10 for 0 to 2 KM</li>
              <li>Rs. 15 for 2 to 4 KM</li>
              <li>Rs. 20 for 4 to 6 KM</li>
              <li>Rs. 25 for 6 to 8 KM</li>
              <li>Rs. 30 for 8 to 10 KM</li>
              <li>Rs. 40 for beyond 10 KM</li>
            </ul>
            <p>
              Passengers can also buy a smart card to avoid queues for token
              purchase.
            </p>
            <ul className="list-disc pl-4 mb-8">
              <li>Deposit: Rs 50</li>
              <li>Upfront discount : 2%</li>
              <li>Reload Promotional amount (above 500): 2%</li>
              <li>Min value for recharge: Rs. 50</li>
              <li>Max value for recharge: Rs. 1000</li>
              <li>Validity: 1 year</li>
              <li>Minimum required balance should be present in CSC for Traveling: Rs. 10</li>
            </ul>
          </section>
        </div>
      </div>
    </>
  );
};

export default NaviMumbaiMetroMap;
