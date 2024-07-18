import Image from "next/image";
import navixplore from "../../assets/images/navixplore-screen.jpg";
import gps from "../../assets/icons/gps.png";
import calendar from "../../assets/icons/calendar.png";
import location from "../../assets/icons/location.png";
import train from "../../assets/icons/train.png";
import rupee from "../../assets/icons/rupee.png";

function NaviXploreAppFeatures() {
  return (
    <>
      <div className="page-heading-section">
        <span className="page-heading text-4xl">
          About NaviXplore - The Guide for Navi Mumbai
        </span>
      </div>

      <div className="page-container mx-auto">
        <div className="lg:col-span-12 mt-4 mb-4 page-description">
          <p>
            NaviXplore is the all-in-one guide app from Navi Mumbai Metro which
            consists of information related to Navi Mumbai Metro timetable, Navi
            Mumbai Metro fare indicator, Express trains (Ticket & PNR status),
            Live Announcements from Metro, Metro route map & services like the
            To convert the given HTML code to Tailwind CSS classes, you can use
            the following: html Copy code
          </p>
          <div className="flex flex-wrap items-center mt-3">
            <div className="md:w-1/3">
              <div className="max-w-md mx-auto rounded-md overflow-hidden shadow-md flex items-center p-4 m-4">
                <div className="mr-4">
                  <Image src={train} alt="train" className="w-14 h-14" />
                </div>
                <div>
                  <h3>
                    The only Navi Mumbai guide app.
                  </h3>
                </div>
              </div>
              <div className="max-w-md mx-auto rounded-md overflow-hidden shadow-md flex items-center p-4 m-4">
                <div className="mr-4">
                  <Image src={gps} alt="gps" className="w-14 h-14" />
                </div>
                <div>
                  <h3>
                    Get live locations of Bus on your smartphone
                  </h3>
                </div>
              </div>
              <div className="max-w-md mx-auto rounded-md overflow-hidden shadow-md flex items-center p-4 m-4">
                <div className="mr-4">
                  <Image src={location} alt="location" className="w-14 h-14" />
                </div>
                <div>
                  <h3>
                    Get A to B routes for Bus.
                  </h3>
                </div>
              </div>
            </div>
            <div className="md:w-1/3">
              <div className="relative mx-auto my-5 border-gray-800 dark:border-gray-800 bg-gray-800 border-[14px] rounded-[2.5rem] h-[600px] w-[300px]">
                <div className="w-[148px] h-[18px] bg-gray-800 top-0 rounded-b-[1rem] left-1/2 -translate-x-1/2 absolute"></div>
                <div className="h-[46px] w-[3px] bg-gray-800 dark:bg-gray-800 absolute -start-[17px] top-[124px] rounded-s-lg"></div>
                <div className="h-[46px] w-[3px] bg-gray-800 dark:bg-gray-800 absolute -start-[17px] top-[178px] rounded-s-lg"></div>
                <div className="h-[64px] w-[3px] bg-gray-800 dark:bg-gray-800 absolute -end-[17px] top-[142px] rounded-e-lg"></div>
                <div className="rounded-[2rem] overflow-hidden w-[272px] h-[572px] bg-white dark:bg-gray-800">
                  <Image
                    src={navixplore}
                    alt="NaviXplore-Screen"
                    className="w-[272px] h-[572px]"
                  />
                </div>
              </div>
            </div>
            <div className="md:w-1/3">
              <div className="max-w-md mx-auto rounded-md overflow-hidden shadow-md flex items-center p-4 m-4">
                <div className="mr-4">
                  <Image src={calendar} alt="calendar" className="w-14 h-14" />
                </div>
                <div>
                  <h3>
                    Latest timetable for bus, metro.
                  </h3>
                </div>
              </div>
              <div className="max-w-md mx-auto rounded-md overflow-hidden shadow-md flex items-center p-4 m-4">
                <div className="mr-4">
                  <Image src={rupee} alt="rupee" className="w-14 h-14" />
                </div>
                <div>
                  <h3>View updated metro fares.</h3>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default NaviXploreAppFeatures;
