import Link from "next/link";
import "./PlacesCard.scss";

function PlacesCard({ data }) {
  return (
    <Link
      className="place-card"
      href={`/places/${encodeURIComponent(data.name)}`}
    >
      <div className="mt-4 mb-4 rounded-2xl">
        <img className="w-full rounded-3xl" src={data.image_url} alt={data.name} />
        <div className="p-4">
          <h2 className="text-xl font-bold mb-2">{data.name}</h2>
          <hr className="my-3" />
          <p className="text-sm text-gray-600">{data.location}</p>
        </div>
      </div>
    </Link>
  );
}

export default PlacesCard;
