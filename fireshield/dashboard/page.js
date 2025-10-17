import { UserButton } from "@clerk/nextjs";

export default function DashboardPage() {
  return (
    <div>
      <header className="w-full flex justify-end p-4">
        <UserButton afterSignOutUrl="/" />
      </header>
      <main className="flex flex-col items-center justify-center">
        <h1 className="text-3xl font-bold">Simulator Dashboard</h1>
        <p className="mt-4">Welcome to the FireShield simulator!</p>
        {/* Your simulator components will go here */}
      </main>
    </div>
  );
}
