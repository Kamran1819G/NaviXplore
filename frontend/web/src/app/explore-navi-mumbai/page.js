"use client";
import { useState, useEffect } from "react";
import PlacesCard from "./PlacesCard";

function ExploreNaviMumbai() {
  const [famousPlaces, setFamousPlaces] = useState([]);
  const [touristDestinations, setTouristDestinations] = useState([]);

  useEffect(() => {
    // Fetch Famous Places from API
    fetch(
      "https://raw.githubusercontent.com/Kamran1819G/NaviXplore-Website-NextJS/master/src/json/FamousPlaces.json"
    )
      .then((response) => response.json())
      .then((data) => setFamousPlaces(data))
      .catch((error) => console.error("Error fetching Famous Places:", error));
  }, []);

  useEffect(() => {
    // Fetch Tourist Destinations from API
    fetch(
      "https://raw.githubusercontent.com/Kamran1819G/NaviXplore-Website-NextJS/master/src/json/TouristDestinations.json"
    )
      .then((response) => response.json())
      .then((data) => setTouristDestinations(data))
      .catch((error) =>
        console.error("Error fetching Tourist Destinations:", error)
      );
  }, []);

  return (
    <>
      <div className="page-heading-section">
        <span className="page-heading text-4xl">Explore Navi Mumbai</span>
      </div>
      <div className="page-container">
        <div className=" lg:col-span-12 mt-4 mb-4">
          <p className="text">
            Uncover the treasures of Navi Mumbai with the NaviXplore App. This
            burgeoning city is known for its modern infrastructure, scenic
            landscapes, and a vibrant cultural scene. Dive into the heart of
            Navi Mumbai&apos;s spirit with NaviXplore as your guide.
          </p>
        </div>
        <div className="lg:col-span-12 mt-4 mb-4">
          <h3 className="section-heading mt-5 mb-4 text-3xl">Famous Places</h3>
          <p>
            NavXplore Guides - Ready to explore the gems of Navi Mumbai? Our
            guide covers everything from serene parks to bustling markets,
            ensuring you experience the essence of this vibrant city.
          </p>
          <div className="grid grid-cols-1 lg:grid-cols-4">
            {famousPlaces.map((item) => (
              <div key={item.id}>
                <PlacesCard data={item} />
              </div>
            ))}
          </div>
        </div>
        <hr className=" h-px my-8 bg-gray-200 border-0 dark:bg-gray-700" />
        <div className="lg:col-span-12 mt-4 mb-4">
          <h3 className="section-heading mt-5 mb-4 text-3xl">
            Tourist Destinations
          </h3>
          <p>
            Need a break from the urban hustle? Explore these nearby
            destinations for a rejuvenating getaway.
          </p>
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-4">
            {touristDestinations.map((item) => (
              <div key={item.id}>
                <PlacesCard data={item} />
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

export default ExploreNaviMumbai;
