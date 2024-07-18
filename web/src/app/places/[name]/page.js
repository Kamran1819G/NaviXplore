'use client'
import { useEffect, useState } from "react";

export default function PlaceInfoPage({params}) {
  const [placeData, setPlaceData] = useState();

  useEffect(() => {
    console.log(decodeURIComponent(params.name));
    Promise.all([
      fetch(
        "https://raw.githubusercontent.com/Kamran1819G/NaviXplore-Website-NextJS/master/src/json/FamousPlaces.json"
      ),
      fetch(
        "https://raw.githubusercontent.com/Kamran1819G/NaviXplore-Website-NextJS/master/src/json/TouristDestinations.json"
      ),
    ])
      .then(([famousResponse, touristResponse]) =>
        Promise.all([famousResponse.json(), touristResponse.json()])
      )
      .then(([famousData, touristData]) => {
        // Combine both datasets
        const combinedData = [...famousData, ...touristData];

        // Find the place data based on the route query
        const selectedPlace = combinedData.find(
          (place) => place.name === decodeURIComponent(params.name)
        );

        if (!selectedPlace) {
          // Place not found, handle the situation (e.g., redirect to an error page)
          console.error(`Place with name ${decodeURIComponent(params.name)} not found`);
          return;
        }

        setPlaceData(selectedPlace);
      })
      .catch((error) => console.error("Error fetching data:", error));
  }, [decodeURIComponent(params.name)]);

  // Inside your return statement:
  if (!placeData) {
    // Optional: Display a message or redirect to an error page
    return <p>Place not found</p>;
  }

  return (
    <>
      <div className="page-heading-section">
        <span className="page-heading text-2xl font-bold mb-4">
          {placeData.name}
        </span>
      </div>
      <div className="postpage mx-auto max-w-3xl">
        <div className="mt-4">
          <img
            className="w-full rounded-2xl"
            src={placeData.image_url}
            alt={placeData.name}
          />
        </div>
        <div className="mt-4 mb-4">
          <p>{placeData.content}</p>
        </div>
        <div className="mt-4">
          <iframe
            title={placeData.name}
            src={placeData.embed_map_url}
            className="w-full h-96"
            allowFullScreen=""
            loading="lazy"
          ></iframe>
        </div>
      </div>
    </>
  );
}
