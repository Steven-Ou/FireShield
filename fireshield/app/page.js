import Link from "next/link";

export default function WelcomePage() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-50 dark:bg-gray-900 text-center p-4">
      <div className="max-w-2xl">
        <h1 className="text-4xl font-bold text-gray-900 dark:text-white sm:text-5xl">
          Welcome to FireShield
        </h1>
        <p className="mt-4 text-lg text-gray-600 dark:text-gray-300">
          This project is a simulation environment designed to help you
          understand and practice cybersecurity concepts in a safe and
          interactive way.
        </p>
        <div className="mt-8">
          <Link
            href="/sign-in"
            className="inline-block px-8 py-3 text-lg font-semibold text-white bg-indigo-600 rounded-lg shadow-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            To Begin
          </Link>
        </div>
      </div>
    </div>
  );
}
