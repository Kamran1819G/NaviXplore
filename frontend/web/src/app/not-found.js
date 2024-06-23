import Link from "next/link";

const NotFound = () => {
  return (
    <main class="grid min-h-full place-items-centerpx-6 py-24 sm:py-32 lg:px-8">
      <div class="text-center">
        <p class="text-base font-semibold text-red-600">404</p>
        <h1 class="mt-4 text-3xl font-bold tracking-tight  sm:text-5xl">
        😓 Page not found
        </h1>
        <p class="mt-6 text-base leading-7">
          Oops! It seems like you&apos;ve wandered into the unknown corners of our website.
        </p>
        <div className="mt-10 flex items-center justify-center gap-x-6">
          <Link
            href="/"
            className="rounded-md px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500"
          >
            Go back home
          </Link>
        </div>
      </div>
    </main>
  );
};

export default NotFound;
