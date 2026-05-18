// Valid job states from your architecture document
export type JobStatus =
  | "CREATED"
  | "MATCHED"
  | "QUOTED"
  | "ACCEPTED"
  | "EN_ROUTE"
  | "ARRIVED"
  | "COMPLETED"
  | "CLOSED"
  | "DISPUTED"
  | "REASSIGNING"
  | "FAILED";

// Which transitions are allowed
const validTransitions: Record<JobStatus, JobStatus[]> = {
  CREATED: ["MATCHED", "FAILED"],
  MATCHED: ["QUOTED", "ACCEPTED", "REASSIGNING", "FAILED"],
  QUOTED: ["ACCEPTED", "REASSIGNING"],
  ACCEPTED: ["EN_ROUTE", "ARRIVED", "REASSIGNING"],
  EN_ROUTE: ["ARRIVED"],
  ARRIVED: ["COMPLETED"],
  COMPLETED: ["CLOSED", "DISPUTED"],
  CLOSED: [],
  DISPUTED: ["CLOSED"],
  REASSIGNING: ["MATCHED", "FAILED"],
  FAILED: [],
};

export function isValidTransition(
  from: JobStatus,
  to: JobStatus
): boolean {
  return validTransitions[from]?.includes(to) ?? false;
}